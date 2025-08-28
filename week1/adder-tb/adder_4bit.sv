// adder_4bit.sv - Design Under Test
module adder_4bit (
    input  logic [3:0] a,      // First operand
    input  logic [3:0] b,      // Second operand
    input  logic       cin,    // Carry in
    output logic [3:0] sum,    // Sum output
    output logic       cout    // Carry out
);

    // Simple behavioral model
    assign {cout, sum} = a + b + cin;

endmodule