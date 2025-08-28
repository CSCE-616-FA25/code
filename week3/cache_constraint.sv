class CacheMemory;
  rand int cacheSize;
  rand int associativity;

  // Constraint to ensure cache size is a power of 2
  constraint size_constraint {
    cacheSize inside {[2**3:2**10]};
    cacheSize % 2 == 0;
  }

  // Constraint to ensure associativity is a power of 2
  constraint assoc_constraint {
    associativity inside {[1:8]};
    is_power_of_2(associativity);
  }

  function automatic int log2_int(int value);
    int log = 0;
    while (value > 1) begin
      value >>= 1;
      log++;
    end
    return log;
  endfunction

  function automatic bit is_power_of_2(int value);
    return (value != 0) && ((value & (value - 1)) == 0);
  endfunction

  // Constructor
  function new();
    cacheSize = 0;
    associativity = 0;
  endfunction

  // Display cache parameters
  function void display();
    $display("Cache Size: %d bytes", cacheSize);
    $display("Associativity: %d-way", associativity);
  endfunction
endclass

module testbench;
  initial begin
    CacheMemory cache;

    // Randomize cache parameters
    cache = new();
    cache.randomize();

    // Display cache parameters
    cache.display();

    $finish;
  end
endmodule
