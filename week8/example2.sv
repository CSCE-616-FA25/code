/*
Description:
The * operator is the repetition operator, and the [3] range operator specifies that the expression should be repeated 3 times.
The ## operator is the delay operator, and the 1 value specifies that there should be a delay of 1 clock cycle between each repetition of the expression.
Therefore, the expression a[*3] equals a ##1 a ##1 a asserts that the signal a will be asserted on the current clock cycle, and then again on the next 2 clock cycles.

Behavior:
This assertion will pass if the signal a is asserted on the current clock cycle, and then again on the next 2 clock cycles. Otherwise, the assertion will fail.
*/

assert property (a[*3]);
assert property (a ##1 a ##1 a);

always @(posedge clk) begin
  a <= 1'b0;
  if (reset) begin
    a <= 1'b0;
  end else begin
    if (start) begin
      a <= 1'b1;
    end else if (a && a_counter == 3) begin
      a <= 1'b0;
    end
  end
  a_counter <= a_counter + 1;
end
