/*
The SystemVerilog expression asserts that the signal a will be followed by the signal !a after a delay of 1 clock cycle, and that the signal !a can be asserted for any number of clock cycles, up to an infinite number of clock cycles, followed by the assertion of the signal a after another delay of 1 clock cycle.

The [=1] range operator specifies that the signal a must be asserted for exactly 1 clock cycle.

The ## operator is the delay operator, and the 1 value specifies that there should be a delay of 1 clock cycle between each assertion.

Therefore, the expression asserts that the following sequence of events will occur:

The signal a will be asserted for 1 clock cycle.
The signal !a will be asserted for any number of clock cycles, up to an infinite number of clock cycles.
The signal a will be asserted for another 1 clock cycle.

Behavior:
This assertion will pass if the signal a is asserted for 1 clock cycle, followed by the signal !a being asserted for any number of clock cycles, up to an infinite number of clock cycles, followed by the signal a being asserted for another 1 clock cycle. Otherwise, the assertion will fail.
*/

assert property (a[=1]);
assert property ((!a)[*0:$] ##1 a ##1 (!a)[*0:$]);

always @(posedge clk) begin
  a <= 1'b0;
  if (reset) begin
    a <= 1'b0;
  end else begin
    if (!a) begin
      a <= 1'b1;
    end else if (a) begin
      a <= 1'b0;
    end
  end
end
