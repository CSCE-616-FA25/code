/*
This program is an example of a testbench using the Universal Verification Methodology (UVM) in SystemVerilog.
It includes UVM components such as a UVM driver, a UVM monitor, and a Design Under Test (DUT). 
*/

`timescale 1ns/1ps

package my_uvm_pkg;
  import uvm_pkg::*;

  class my_transaction extends uvm_sequence_item;
    // Randomizable fields
    rand bit [7:0] addr;
    rand bit [31:0] data;

    `uvm_object_utils(my_transaction)

    function new(string name = "");
      super.new(name);
    endfunction

    function void do_print(uvm_printer printer);
      super.do_print(printer); // (The parent class is called the Superclass)
      printer.print_field("addr", addr, $bits(addr));
      printer.print_field("data", data, $bits(data));
    endfunction

    virtual function string convert2string; // This function can be overridden in any dereived class
      return $sformatf("addr=%h, data=%h", addr, data);
    endfunction
  endclass

  class my_driver extends uvm_driver#(my_transaction);
    `uvm_component_utils(my_driver)

    function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      my_transaction tx;
      forever begin
        if (seq_item_port.get_next_item(tx)) begin
          `uvm_info(get_type_name(), $sformatf("Sending transaction: %s", tx.convert2string()), UVM_LOW)
          // Drive the DUT with the transaction
          // ...
          // Optionally, sample response from DUT
          // ...
          seq_item_port.item_done();
        end
      end
    endtask
  endclass

  class my_monitor extends uvm_monitor;
    `uvm_component_utils(my_monitor)

    my_transaction tx;

    function new(string name = "my_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      forever begin
        // Sample signals from the DUT and build a transaction
        // ...
        // Optionally, check for specific conditions
        // ...
        `uvm_info(get_type_name(), $sformatf("Monitoring transaction: %s", tx.convert2string()), UVM_LOW)
        seq_item_port.put_response(tx);
      end
    endtask
  endclass
endpackage

module my_dut(/* DUT ports and signals */);
  // Implement your Design Under Test (DUT) logic here
  // ...
endmodule

module testbench;
  import my_uvm_pkg::*;

  initial begin
    // Configurations
    // For all components in the test, set the default sequence to be - my_sequence
    uvm_config_db#(uvm_object_wrapper)::set(null, "*", "default_sequence", my_sequence::type_id::get());

    // For all instances of my_sequence set the my_seq_length parameter to 10
    uvm_config_db#(int)::set(null, "*", "my_sequence", "my_seq_length", 10);

    //Start the UVM test
    run_test();
  end

  initial begin
    // Create the DUT instance
    my_dut dut(/* DUT ports and signals */);

    // Create UVM components
    my_driver driver;
    my_monitor monitor;
    my_sequence seq;

    // Connect UVM components
    seq.starting_phase.connect(driver.phase_done);
    driver.seq_item_port.connect(seq.seq_item_export);
    monitor.seq_item_port.connect(seq.seq_item_export);

    // Start the UVM simulation
    run_test();

    // Wait for simulation to finish
    wait($finish);
  end
endmodule

module top;
  // Instantiate the testbench
  testbench tb();

  // Connect DUT ports to the testbench
  my_dut dut(/* DUT ports and signals */);
  // ...

  // Connect DUT signals to the testbench
  // ...

  // Instantiate and connect any additional components
  // ...

  // Add any necessary simulation setup code
  // ...

  // Start the simulation
  initial begin
    $dumpfile("simulation.vcd");
    $dumpvars(0, top);

    // Simulate for a specific duration or until a condition is met
    #10000;
    
    $display("Simulation completed");
    $finish;
  end
endmodule
