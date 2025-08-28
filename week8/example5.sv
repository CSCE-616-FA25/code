/*
The SystemVerilog property adder asserts that the output of the adder (data_out) will be equal to the input (x) plus 1, after a delay of 5 clock cycles, if the adder is enabled (valid is asserted and res_n is deasserted).

Behavior:
The adder property can be used to verify the functionality of a 64-bit adder. To use the property, you would first need to instantiate it in your testbench. Once the property has been instantiated, you can then apply test vectors to the adder and check the results to see if they match the property. If the results do not match the property, then the assertion will fail and you will know that there is a problem with the adder.
*/

property adder;
bit [63:0] x;
@(posedge clk) disable iff (!res_n)
(valid, x = data_in) |=> ##5 (data_out == (x+1));
endproperty : adder