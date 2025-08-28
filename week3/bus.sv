// Simulation of a memory mapped bus communication system in SystemVerilog

class Bus;
  rand bit [31:0] data;
  rand bit [7:0] address;
  bit [31:0] memory[256]; // An array of 256 32-bit element

  // constructor
  function new();
    data = 0;
    address = 0;
    memory = new[256];
    // Each memory location is initialized with a random value
    memory.randomize() with { item == $random; };
  endfunction

  task read(input bit [7:0] addr, output bit [31:0] data);
    address = addr;
    data = memory[addr];
    $display("Read from address 0x%h, Data: 0x%h", addr, data);
  endtask

  task write(input bit [7:0] addr, input bit [31:0] data);
    address = addr;
    memory[addr] = data;
    $display("Write to address 0x%h, Data: 0x%h", addr, data);
  endtask
endclass

// CPU parameterazid with a Bus object
module CPU #(Bus bus);
  initial begin
    bit [31:0] read_data;
    bit [31:0] write_data;

    bus.read(0x10, read_data);

    write_data = read_data + 1;
    bus.write(0x10, write_data);
  end
endmodule

module GPU #(Bus bus);
  initial begin
    bit [31:0] read_data;

    bus.read(0x20, read_data);
  end
endmodule

// Top level
module TestBus;
  Bus bus = new();
  // Same bus instance is passed as an argument to CPU and GPU
  CPU #(bus) cpu();
  GPU #(bus) gpu();
  
  initial begin
    // Simulation 
    $finish;
  end
endmodule
