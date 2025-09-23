///////////////////////////////////////////////////////////////////////////
// ASSERTIONS vs CHECKERS: Side-by-Side Examples for HTAX
///////////////////////////////////////////////////////////////////////////

//=======================================================================
// EXAMPLE 1: Checking if tx_outport_req is one-hot when asserted
//=======================================================================

//--------------------------- ASSERTION WAY ---------------------------
// Simple, declarative, automatic checking
property tx_outport_onehot_prop;
  @(posedge clk) |tx_outport_req |-> $onehot(tx_outport_req);
endproperty

assert property (tx_outport_onehot_prop) 
  else $error("tx_outport_req is not one-hot!");

//--------------------------- CHECKER WAY -----------------------------
// Procedural, more control, custom reporting
always_ff @(posedge clk) begin
  if (|tx_outport_req) begin // If any bit is asserted
    int count = 0;
    for (int i = 0; i < `PORTS; i++) begin
      if (tx_outport_req[i]) count++;
    end
    
    if (count != 1) begin
      $error("CHECKER: tx_outport_req[%b] has %0d bits set, expected 1", 
             tx_outport_req, count);
      // Could add more debugging info here
      $display("Time: %0t, Port pattern: %b", $time, tx_outport_req);
    end
  end
end

//=======================================================================
// EXAMPLE 2: tx_vc_req and tx_outport_req must be asserted together
//=======================================================================

//--------------------------- ASSERTION WAY ---------------------------
property req_together_prop;
  @(posedge clk) (|tx_vc_req) <-> (|tx_outport_req);
endproperty

assert property (req_together_prop)
  else $error("tx_vc_req and tx_outport_req not asserted together!");

//--------------------------- CHECKER WAY -----------------------------
always_ff @(posedge clk) begin
  logic vc_active = |tx_vc_req;
  logic port_active = |tx_outport_req;
  
  if (vc_active != port_active) begin
    $error("CHECKER: Signal mismatch at time %0t", $time);
    $display("  tx_vc_req = %b (active=%b)", tx_vc_req, vc_active);
    $display("  tx_outport_req = %b (active=%b)", tx_outport_req, port_active);
    
    // Additional context
    if (vc_active && !port_active)
      $display("  ERROR: VC requested but no port specified");
    else if (!vc_active && port_active)
      $display("  ERROR: Port requested but no VC specified");
  end
end

//=======================================================================
// EXAMPLE 3: Transaction must start with SOT and end with EOT
//=======================================================================

//--------------------------- ASSERTION WAY ---------------------------
// Simple SOT check
property sot_with_data_prop;
  @(posedge clk) |tx_sot |-> (tx_data !== 'x);
endproperty

assert property (sot_with_data_prop)
  else $error("SOT asserted without valid data");

// Simple EOT check  
property eot_ends_transaction_prop;
  @(posedge clk) tx_eot |=> !tx_sot[*1:$]; // No SOT immediately after EOT
endproperty

assert property (eot_ends_transaction_prop)
  else $error("Transaction framing violation");

//--------------------------- CHECKER WAY -----------------------------
class transaction_checker;
  bit transaction_active = 0;
  int packet_count = 0;
  logic [WIDTH-1:0] packet_data[$];
  
  task check_transaction_flow();
    forever begin
      @(posedge clk);
      
      // Check for SOT
      if (|tx_sot) begin
        if (transaction_active) begin
          $error("CHECKER: SOT asserted during active transaction!");
          $display("  Previous transaction had %0d packets", packet_count);
        end
        
        transaction_active = 1;
        packet_count = 1;
        packet_data.push_back(tx_data);
        
        // Verify SOT is one-hot
        if (!$onehot(tx_sot)) begin
          $error("CHECKER: tx_sot is not one-hot: %b", tx_sot);
        end
        
        $display("CHECKER: Transaction started on VC %0d with data %h", 
                $clog2(tx_sot), tx_data);
      end
      
      // Check ongoing transaction
      else if (transaction_active && !tx_eot) begin
        packet_count++;
        packet_data.push_back(tx_data);
        
        if (tx_data === 'x) begin
          $error("CHECKER: Invalid data in packet %0d", packet_count);
        end
      end
      
      // Check for EOT
      if (tx_eot) begin
        if (!transaction_active) begin
          $error("CHECKER: EOT without active transaction!");
        end else begin
          $display("CHECKER: Transaction completed - %0d packets, total data: %p", 
                  packet_count, packet_data);
        end
        
        transaction_active = 0;
        packet_count = 0;
        packet_data.delete();
      end
    end
  endtask
endclass

//=======================================================================
// EXAMPLE 4: Grant should follow request within reasonable time
//=======================================================================

//--------------------------- ASSERTION WAY ---------------------------
// Grant should come within 10 cycles of request
property grant_follows_request_prop;
  @(posedge clk) $rose(|tx_vc_req) |-> ##[1:10] |tx_vc_gnt;
endproperty

assert property (grant_follows_request_prop)
  else $error("Grant timeout - no grant within 10 cycles");

//--------------------------- CHECKER WAY -----------------------------
class grant_timeout_checker;
  int request_time[$];
  bit [VC-1:0] pending_requests = 0;
  
  always_ff @(posedge clk) begin
    // Track new requests
    for (int i = 0; i < VC; i++) begin
      if (tx_vc_req[i] && !pending_requests[i]) begin
        pending_requests[i] = 1;
        request_time.push_back($time);
        $display("CHECKER: VC[%0d] request at time %0t", i, $time);
      end
    end
    
    // Check for grants
    for (int i = 0; i < VC; i++) begin
      if (tx_vc_gnt[i] && pending_requests[i]) begin
        pending_requests[i] = 0;
        int req_time = request_time.pop_front();
        int latency = ($time - req_time) / 10; // Convert to cycles
        
        $display("CHECKER: VC[%0d] granted after %0d cycles", i, latency);
        
        if (latency > 10) begin
          $error("CHECKER: Grant timeout for VC[%0d] - took %0d cycles", 
                i, latency);
        end else if (latency > 5) begin
          $warning("CHECKER: Slow grant for VC[%0d] - took %0d cycles", 
                  i, latency);
        end
      end
    end
    
    // Check for timeouts (requests pending too long)
    if (pending_requests != 0 && ($time % 100 == 0)) begin // Check every 100ns
      for (int i = 0; i < VC; i++) begin
        if (pending_requests[i] && request_time.size() > 0) begin
          int age = ($time - request_time[0]) / 10;
          if (age > 20) begin
            $error("CHECKER: VC[%0d] request has been pending for %0d cycles!", 
                  i, age);
          end
        end
      end
    end
  end
endclass

//=======================================================================
// EXAMPLE 5: Data integrity across transaction
//=======================================================================

//--------------------------- ASSERTION WAY ---------------------------
// Data should remain stable during valid periods
property data_stable_prop;
  @(posedge clk) $stable(tx_data) throughout (tx_sot ##1 tx_eot[->1]);
endproperty

// This is hard to express in assertions for complex scenarios!

//--------------------------- CHECKER WAY -----------------------------
class data_integrity_checker;
  logic [WIDTH-1:0] expected_data[$];
  bit monitoring = 0;
  
  // Initialize with expected data pattern
  function void set_expected_data(logic [WIDTH-1:0] data_array[]);
    expected_data = {data_array};
  endfunction
  
  always_ff @(posedge clk) begin
    if (|tx_sot) begin
      monitoring = 1;
      
      // Check first packet
      if (expected_data.size() > 0) begin
        if (tx_data !== expected_data[0]) begin
          $error("CHECKER: Data mismatch in first packet");
          $display("  Expected: %h, Got: %h", expected_data[0], tx_data);
        end else begin
          $display("CHECKER: First packet data correct: %h", tx_data);
        end
        expected_data.pop_front();
      end
    end
    
    else if (monitoring && !tx_eot) begin
      // Check subsequent packets
      if (expected_data.size() > 0) begin
        if (tx_data !== expected_data[0]) begin
          $error("CHECKER: Data mismatch in packet");
          $display("  Expected: %h, Got: %h", expected_data[0], tx_data);
        end
        expected_data.pop_front();
      end
      
      // Check for data corruption
      if (tx_data === 'x || tx_data === 'z) begin
        $error("CHECKER: Corrupted data detected: %h", tx_data);
      end
    end
    
    if (tx_eot) begin
      monitoring = 0;
      if (expected_data.size() > 0) begin
        $error("CHECKER: Transaction ended but %0d packets still expected", 
              expected_data.size());
      end
      $display("CHECKER: Transaction data integrity check complete");
    end
  end
endclass

