class Memory_Transaction; // Single memory operation
  rand bit [31:0] address;
  rand bit [31:0] data;
  rand bit read_write; // 0 for read, 1 for write

  constraint valid_address { address[1:0] == 2'b00; } // Word-aligned addresses - multiples of 4
endclass

class Memory_Driver;
  virtual memory_if vif;

  task drive(Memory_Transaction trans);
    @(posedge vif.clk);
    vif.address <= trans.address;
    vif.read_write <= trans.read_write;
    if (trans.read_write) vif.write_data <= trans.data;
    vif.valid <= 1;
    @(posedge vif.clk);
    while (!vif.ready) @(posedge vif.clk);
    if (!trans.read_write) trans.data = vif.read_data;
    vif.valid <= 0;
  endtask
endclass

// In testbench
initial begin
  Memory_Transaction trans;
  Memory_Driver driver;

  repeat(100) begin
    trans = new();
    assert(trans.randomize());
    driver.drive(trans);
    if (!trans.read_write) 
      $display("Read data: %h from address: %h", trans.data, trans.address);
  end
end

/*
Abstraction:
The class Memory_Transaction abstrcats away the details of the memory interface.
Test writer thinks in terms of high-levl operations

Reusability of the same transaction class: --- Stimuli , driver of the DUT, check responses

Randomization
*/
