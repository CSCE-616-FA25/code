// tb_adder_4bit.sv - Basic Testbench
module tb_adder_4bit;

    // Testbench signals
    logic [3:0] a, b;
    logic       cin;
    logic [3:0] sum;
    logic       cout;
    
    // Expected results for self-checking
    logic [3:0] expected_sum;
    logic       expected_cout;
    
    // Test statistics
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;

    // Instantiate the Design Under Test (DUT)
    adder_4bit dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    // Test procedure
    initial begin
        $display("Starting 4-bit Adder Testbench");
        $display("Time\t a\t b\tcin\tsum\tcout\tExpected\tResult");
        $display("----\t---\t---\t---\t---\t----\t--------\t------");
        
        // Test Case 1: Simple addition without carry
        test_case(4'b0001, 4'b0010, 1'b0, "Simple addition");
        
        // Test Case 2: Addition with carry in
        test_case(4'b0101, 4'b0011, 1'b1, "Addition with carry in");
        
        // Test Case 3: Maximum values
        test_case(4'b1111, 4'b1111, 1'b1, "Maximum values");
        
        // Test Case 4: Zero addition
        test_case(4'b0000, 4'b0000, 1'b0, "Zero addition");
        
        // Test Case 5: Carry propagation
        test_case(4'b0111, 4'b0001, 1'b0, "Carry propagation");
        
        // Test Case 6: Boundary test
        test_case(4'b1000, 4'b1000, 1'b0, "Boundary test");
        
        // More comprehensive testing with random values
        repeat(10) begin
            random_test();
        end
        
        // Final report
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        
        if (fail_count == 0)
            $display("*** ALL TESTS PASSED! ***");
        else
            $display("*** %0d TESTS FAILED ***", fail_count);
            
        $finish;
    end

    // Task to run individual test cases
    task test_case(
        input [3:0] test_a,
        input [3:0] test_b,
        input       test_cin,
        input string description
    );
        // Apply inputs
        a = test_a;
        b = test_b;
        cin = test_cin;
        
        // Calculate expected results
        {expected_cout, expected_sum} = test_a + test_b + test_cin;
        
        // Wait for combinational logic to settle
        #10;
        
        // Check results
        test_count++;
        if (sum === expected_sum && cout === expected_cout) begin
            $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b%b\t\tPASS - %s", $time, a, b, cin, sum, cout, expected_cout, expected_sum, description);
            pass_count++;
        end else begin
            $display("%0t\t%b\t%b\t%b\t%b\t%b\t%b%b\t\tFAIL - %s",  $time, a, b, cin, sum, cout, expected_cout, expected_sum, description);
            $display("\t\tExpected: sum=%b, cout=%b | Got: sum=%b, cout=%b", expected_sum, expected_cout, sum, cout);
            fail_count++;
        end
    endtask

    // Task for random testing
    task random_test();
        logic [3:0] rand_a, rand_b;
        logic       rand_cin;
        
        // Generate random inputs
        rand_a = $random;
        rand_b = $random;
        rand_cin = $random;
        
        test_case(rand_a, rand_b, rand_cin, "Random test");
    endtask

endmodulecd 