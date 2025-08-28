class CacheLine;
  int tag;
  bit [31:0] data;
  
  function new(int t);
    tag = t; // default tag
    data = 0; // Initial values
  endfunction
  
  function void write(int t, bit [31:0] d);
    if (t == tag)
      data = d;
  endfunction
  
  function bit [31:0] read(int t);
    if (t == tag)
      return data;
    else
      return 0;
  endfunction
endclass  // end

class CacheMemory;
  CacheLine cache[16];
  
  function void init();
    foreach (cache[i]) begin
      cache[i] = new(i);
    end
  endfunction
  
  function void write(int address, bit [31:0] data);
    int line = address % 16; // This calculates the number of the cache line
    cache[line].write(address / 16, data);
  endfunction
  
  function bit [31:0] read(int address);
    int line = address % 16;
    return cache[line].read(address / 16);
  endfunction
endclass

module test_cache;
  CacheMemory cache_mem;
  
  initial begin
    cache_mem.init();
    
    // Write data to cache memory
    cache_mem.write(0x1000, 32'hABCDEFF0);
    cache_mem.write(0x2000, 32'h12345678);
    
    // Read data from cache memory
    $display("Data at address 0x1000: 0x%h", cache_mem.read(0x1000));
    $display("Data at address 0x2000: 0x%h", cache_mem.read(0x2000));
    $display("Data at address 0x3000: 0x%h", cache_mem.read(0x3000));
    
    // Output:
    // Data at address 0x1000: 0xABCDEFF0
    // Data at address 0x2000: 0x12345678
    // Data at address 0x3000: 0
  end
endmodule
