module memory_controller(
  input clk, reset,
  input [31:0] address, write_data,
  input read_write, valid,
  output reg [31:0] read_data,
  output reg ready
);

  // Controller implementation...

  // Assertions
  // 1- write the assertations
  property valid_ready_relation;
    @(posedge clk) valid |-> ##[1:5] ready;
  endproperty

  // 2- check the assertations
  assert property (valid_ready_relation)
    else $error("Ready not asserted within 5 cycles of Valid");

   // 1- write the assertations
  property no_address_change;
  // next cycle implication - if the left side is true, the right side must be true in the next cycle
    @(posedge clk) (valid && !ready) |=> $stable(address); // next cycle implication
  endproperty

  // 2 - Check the assertions
  assert property (no_address_change)
    else $error("Address changed while transaction in progress");

 // 1- write the assertations
  property read_data_valid;
    @(posedge clk) (ready && !read_write) |-> !$isunknown(read_data); // implication: read_date must have a known value
  endproperty
  // 2 - Check the assertions
  assert property (read_data_valid)
    else $error("Read data is unknown when ready asserted");

  // Assume statements for inputs
  assume property (@(posedge clk) !$isunknown(valid));
  assume property (@(posedge clk) valid |-> !$isunknown(address));

endmodule


/**
A large number of complex assertions can slow down simulation
/