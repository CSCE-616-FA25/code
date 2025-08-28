// Test-Bench fragment for 2-way arbiter

module top;
reg clk, r1, r2;
wire g1, g2;
arbiter A(.r1(r1), .r2(r2), .g1(g1), .g2(g2), .clk(clk));
// Clock generator
always #1 clk = ∼ clk;

// Model for Master-1
always @(posedge clk)
begin
    r1 = 1;
    @(posedge g1) r1 = 0;
    @(posedge clk); @(posedge clk);
end

// Model for Master-2
always @(posedge clk)
begin
    r2 = 1;
    @(posedge g2) r2 = 0;
end
endmodule

