/*
This program models a memory module with random write and read operations while ensuring that input values are within specified constraints. 
*/

module memory (
    input logic [7:0] write_data,
    input logic [7:0] read_data,
    input logic [3:0] address,
    input logic write_enable,
    input logic read_enable
);

    // Define the memory array
    logic [7:0] mem [15:0];

    // Constraint distribution
    initial begin
        // Constraint on the address input (0 to 15)
        address inside {[0:15]};

        // Constraint on write_data and read_data (8-bit data)
        write_data inside {[0:255]};
        read_data inside {[0:255]};

        // Constraint for enabling write or read (1 or 0)
        write_enable inside {[0:1]};
        read_enable inside {[0:1]};

        // Randomize the inputs while respecting constraints
        repeat(10) begin // 10 random operatins on memory
            if (write_enable == 1'b1) begin
                // Randomize address and data for write operation
                address.randomize();
                write_data.randomize();
                // Perform a write operation
                mem[address] = write_data;
                $display("Write Operation: Address = %0d, Data = %h", address, write_data);
            end else if (read_enable == 1'b1) begin
                // Randomize address for read operation
                address.randomize();
                // Perform a read operation
                read_data = mem[address];
                $display("Read Operation: Address = %0d, Data = %h", address, read_data);
            end
            // Randomize write_enable and read_enable for the next operation
            write_enable.randomize();
            read_enable.randomize();
            // Pause for visualization
            #10;
        end
        // End simulation
        $finish;
    end

endmodule
