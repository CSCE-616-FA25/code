/*
The SystemVerilog expression below asserts that the signal `a` will be followed by the signal `b`, after a delay of at least 3 clock ticks and up to an infinite number of clock ticks.
The `##` operator is the delay operator, and the `[3:]` range operator specifies that the delay can be any value from 3 to infinity.
This expression asserts that a certain sequence of events will occur, such as a request being followed by a response, or a data signal being followed by a clock pulse.

Behavior:
This assertion will pass if the signal b is asserted at least 3 clock ticks after the signal a is asserted. Otherwise, the assertion will fail.
*/

assert property (a ##[3:$] b);

always @(posedge clk) begin
  a <= 1'b0;
  if (reset) begin
    b <= 1'b0;
  end else begin
    if (a) begin
      b <= 1'b1;
    end
  end
end