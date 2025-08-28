/*
this SystemVerilog program demonstrates the use of constraint constructs to define constraints on a register 
and then uses a randomization object to generate a random value for the register while ensuring it adheres to the specified constraints.
*/

module Register;
  // Declare the 8-bit register
  reg [7:0] data;

  // Define a constraint block
  constraint data_constraint {
    // Constrain the data to be between 10 and 50
    data >= 10;
    data <= 50;

    // Constrain the data to be even
    data % 2 == 0;

    // Constrain the data to be a multiple of 4
    data % 4 == 0;
  }

  initial begin
    // Create a randomization object
    automatic rand r;

    // Apply the constraint to the randomization object
    r = new;

    r.constraint(data_constraint);

    // Randomize the data
    if (r.randomize(data)) begin
      $display("Randomized data: %d", data);
    end else begin
      $display("Randomization failed");
    end
  end
endmodule
