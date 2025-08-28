/*
Example of object-oriented programming (OOP) in SystemVerilog
*/

class MyCounter;
  // Declare class properties
  int count;
  
  // Constructor
  function new();
    count = 0;
  endfunction
  
  // Class method to increment the count
  function void increment();
    count = count + 1;
  endfunction
  
  // Class method to get the current count
  function int get_count();
    return count;
  endfunction
endclass

module test;
  // Create an object of the MyCounter class
  MyCounter counter1 = new();
  MyCounter counter2 = new();
  
  initial begin
    // Use object methods to manipulate counters
    counter1.increment();
    counter1.increment();
    
    counter2.increment();
    
    $display("Counter 1 count: %d", counter1.get_count());
    $display("Counter 2 count: %d", counter2.get_count());
    
    // Output:
    // Counter 1 count: 2
    // Counter 2 count: 1
  end
endmodule
