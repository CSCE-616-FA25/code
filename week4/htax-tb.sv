`timescale 1ns/1ps

package htax_uvm_pkg;
  import uvm_pkg::*;

  // HTAX Transaction
  class htax_transaction extends uvm_sequence_item;
    rand bit [3:0] src_port;
    rand bit [3:0] dst_port;
    rand bit [VC-1:0] vc;
    rand bit [WIDTH-1:0] data;
    rand bit is_sot;
    rand bit is_eot;
    rand bit release_gnt;

    `uvm_object_utils_begin(htax_transaction)
      `uvm_field_int(src_port, UVM_ALL_ON)
      `uvm_field_int(dst_port, UVM_ALL_ON)
      `uvm_field_int(vc, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(is_sot, UVM_ALL_ON)
      `uvm_field_int(is_eot, UVM_ALL_ON)
      `uvm_field_int(release_gnt, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "htax_transaction");
      super.new(name);
    endfunction

    constraint valid_ports {
      src_port inside {[0:PORTS-1]};
      dst_port inside {[0:PORTS-1]};
      src_port != dst_port;
    }

    constraint valid_vc {
      vc inside {[0:VC-1]};
    }
  endclass

  // HTAX Driver
  class htax_driver extends uvm_driver #(htax_transaction);
    `uvm_component_utils(htax_driver)

    virtual htax_if vif; // Connects to the DUT

    function new(string name = "htax_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual htax_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
      htax_transaction tx;
      forever begin
        seq_item_port.get_next_item(tx);
        drive_transaction(tx); // Implemented |--->
        seq_item_port.item_done();
      end
    endtask

    task drive_transaction(htax_transaction tx);
      @(posedge vif.clk);
      vif.tx_outport_req[tx.dst_port] <= 1'b1;
      vif.tx_vc_req[tx.vc] <= 1'b1;
      
      @(posedge vif.clk);
      while (vif.tx_vc_gnt[tx.vc] !== 1'b1) @(posedge vif.clk);
      
      vif.tx_data <= tx.data;
      vif.tx_sot[tx.vc] <= tx.is_sot;
      vif.tx_eot <= tx.is_eot;
      vif.tx_release_gnt <= tx.release_gnt;
      
      @(posedge vif.clk);
      vif.tx_outport_req[tx.dst_port] <= 1'b0;
      vif.tx_vc_req[tx.vc] <= 1'b0;
    endtask
  endclass

  // HTAX Monitor
  class htax_monitor extends uvm_monitor;
    `uvm_component_utils(htax_monitor)

    virtual htax_if vif;
    uvm_analysis_port #(htax_transaction) ap;

    function new(string name = "htax_monitor", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual htax_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
      htax_transaction tx;
      forever begin
        tx = htax_transaction::type_id::create("tx");
        collect_transaction(tx);
        ap.write(tx);
      end
    endtask

    task collect_transaction(htax_transaction tx);
      @(posedge vif.clk);
      if (vif.tx_outport_req != 0) begin
        tx.dst_port = $clog2(vif.tx_outport_req);
        tx.vc = $clog2(vif.tx_vc_req);
        tx.data = vif.tx_data;
        tx.is_sot = |vif.tx_sot;
        tx.is_eot = vif.tx_eot;
        tx.release_gnt = vif.tx_release_gnt;
      end
    endtask
  endclass

  // HTAX Scoreboard - Check for correctness
  class htax_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(htax_scoreboard)

    uvm_analysis_export #(htax_transaction) sb_export;
    uvm_tlm_analysis_fifo #(htax_transaction) fifo;

    function new(string name = "htax_scoreboard", uvm_component parent = null);
      super.new(name, parent);
      sb_export = new("sb_export", this);
      fifo = new("fifo", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_export.connect(fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      htax_transaction tx;
      forever begin
        fifo.get(tx);
        check_transaction(tx);
      end
    endtask

    function void check_transaction(htax_transaction tx);
      // Implement checking logic here !!!
      `uvm_info(get_type_name(), $sformatf("Checking transaction: dst=%0d, vc=%0d, data=%0h", 
                                           tx.dst_port, tx.vc, tx.data), UVM_LOW)
    endfunction
  endclass

  // HTAX Environment
  class htax_env extends uvm_env;
    `uvm_component_utils(htax_env)

    htax_driver driver;
    htax_monitor monitor;
    htax_scoreboard scoreboard;

    function new(string name = "htax_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      driver = htax_driver::type_id::create("driver", this);
      monitor = htax_monitor::type_id::create("monitor", this);
      scoreboard = htax_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      monitor.ap.connect(scoreboard.sb_export);
    endfunction
  endclass

  // HTAX Test
  class htax_test extends uvm_test;
    `uvm_component_utils(htax_test)

    htax_env env;

    function new(string name = "htax_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = htax_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      htax_transaction tx;
      phase.raise_objection(this);
      repeat(100) begin
        tx = htax_transaction::type_id::create("tx");
        assert(tx.randomize());
        env.driver.seq_item_port.put(tx);
      end
      #100;
      phase.drop_objection(this);
    endtask
  endclass

endpackage

interface htax_if(input bit clk);
  logic [PORTS-1:0] tx_outport_req;
  logic [VC-1:0] tx_vc_req;
  logic [VC-1:0] tx_vc_gnt;
  logic [WIDTH-1:0] tx_data;
  logic [VC-1:0] tx_sot;
  logic tx_eot;
  logic tx_release_gnt;
endinterface

module top;
  import uvm_pkg::*;
  import htax_uvm_pkg::*;

  bit clk;
  always #5 clk = ~clk;

  htax_if vif(clk);

  initial begin
    uvm_config_db#(virtual htax_if)::set(null, "*", "vif", vif);
    run_test("htax_test");
  end
endmodule