covergroup Memory_Coverage; // What?
  // track coverage of address ranges
  address: coverpoint trans.address {
    bins low = {[32'h1000:32'h1FFF]};
    bins high = {[32'h8000:32'h8FFF]};
  }

  // Track coverage of data values
  data: coverpoint trans.data {
    bins low = {[32'h0:32'hFF]};
    bins high = {[32'hFF00:32'hFFFF]};
  }

  // Track the coverage of read and write operations
  // Implicitly create two bins : 0 (read) , 1 (write)
  read_write: coverpoint trans.read_write;
  
  // Creates a cross product of the Coverpoints address, data, read_write
  address_data_cross: cross address, data, read_write;
endcovergroup

// In testbench
initial begin
  Memory_Transaction trans;
  Memory_Driver driver;
  Memory_Coverage cov;

  cov = new();

  repeat(10000) begin
    trans = new();
    assert(trans.randomize());
    driver.drive(trans);
    cov.sample(); // Update the coverage metrics

    // Check coverage and adjust constraints if needed
    // This ensures we diont waste on redundant tests
    if (cov.get_coverage() >= 100) break;
  end

  $display("Final coverage: %f%%", cov.get_coverage());
end

/*
Benefits
Completeness
Efficiency
Quantifiable
Targeted testing

Challenges?
Defining good coverage models
Coverage closure: < 100%
High coverage does not guarantee the absence of bug!
*/