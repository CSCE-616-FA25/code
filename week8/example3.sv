/*
The SystemVerilog expression asserts that the signal `a` will be followed by the signal `!a` after a delay of 1 clock cycle, and that the signal `!a` can be asserted for any number of clock cycles, up to an infinite number of clock cycles.
The `->` operator is the toggle operator, and it asserts that the signal `a` will toggle to its opposite value.
The `[*0:]range operator specifies that the signal!a` can be asserted for any number of clock cycles, up to an infinite number of clock cycles.

The ## operator is the delay operator, and the 1 value specifies that there should be a delay of 1 clock cycle between the assertion of the signal !a and the assertion of the signal a.

Therefore, the expression a[->1] equals (!a)[*0:$] ##1 a asserts that the signal a will toggle to its opposite value, and that the opposite value can be asserted for any number of clock cycles, up to an infinite number of clock cycles, followed by the assertion of the signal a after a delay of 1 clock cycle.

Behavior:
This assertion will pass if the signal a toggles to its opposite value, and the opposite value is asserted for any number of clock cycles, up to an infinite number of clock cycles, followed by the assertion of the signal a after a delay of 1 clock cycle. Otherwise, the assertion will fail.
*/

assert property (a[->1]);
assert property ((!a)[*0:$] ##1 a);

always @(posedge clk) begin
  a <= 1'b0;
  if (reset) begin
    a <= 1'b0;
  end else begin
    if (!a) begin
      a <= 1'b1;
    end
  end
end