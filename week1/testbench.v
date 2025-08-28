`timescale 1ns/1ps

modeule testbench;

	// parameters
	parameter CLK_PERIOD = 10;

	// Signals
	reg clk;
	reg reset;
	reg [7:0] input_data;
	wire [7:0] output_data;

	// Clock generation
	always #(CLK_PERIOD / 2) clk = ~clk;

	// DUT instantiation
	dut my_dut (
		.clk(clk),
		.reset(reset),
		.input_data(input_data),
		.output_data(output_data)
	);


	// Test stimulus
	initial begin
		// Initialize
		clk = 0;
		reset =1;
		input_data = 8'h00;

		// Reset sequence
		#20 reset = 0;

		// Test case 1
		#10 input_data = 8'hAA;
		#10 $display("Output: %h", output_data);

		// Test case 2
		#10 input_data = 8'h55;
		#10 $display("Output: %h, output_data);

		# End simulation
		#10 $finish

	end

	// Optional: Waveform dump
	initial begin
		$dumpfile ("testbench.vcd");
		$dumpvars (0, testbench);
	end
endmodule
