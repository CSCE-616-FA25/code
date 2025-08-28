wire  s1, s2, s3;

property  p1;
  @(posedge  clk)  disable  iff(!res_n)
    (  s1  &&  s2  )  |=>  s3;
endproperty: p1

assert  property  (p1);

/*
A short form:
assert  property(@(posedge  clk)  disable  iff(!res_n)
( s1  &&  s2 )  |=>  s3);
*/
