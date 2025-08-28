/*
In this example, the bind construct binds the assertion module instance, assertions_I, to the DUT instance, dut_I.
The bind construct also connects the clk, res_n, req, and gnt signals between the DUT and assertion module.
*/

module   assertion_module(
input   logic   clk,
       input   logic   res_n,
       input   logic   req,
input   logic   gnt
);

req_gnt   :   assert   property(
@(posedge   clk)   disable   iff(!res_n)   req   |=>   gnt);
endmodule

module   tb_top;
wire   clk_top,   res_n_top,   req_top,   gnt_top;
dut   dut_I(   //   of   type   dut
.clk(clk_top),   .res_n(res_n_top),
.req(req_top),   .gnt(gnt_top)
);

bind   dut   :   tb_top.dut_I   assertion_module   assertions_I   (
.clk(clk),   .res_n(res_n),   .req(req),   .gnt(gnt)

);
endmodule
