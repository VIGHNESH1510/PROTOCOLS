module SPI_tb;

  reg clk, areset, CPOL, CPHA;
  reg  [7:0] data_M, data_S;
  wire [7:0] data_in_M, data_in_S;
  wire done_M, done_S;

  top_module DUT (
    .clk(clk),
    .areset(areset),
    .CPOL(CPOL),
    .CPHA(CPHA),
    .data_M(data_M),
    .data_S(data_S),
    .data_in_M(data_in_M),
    .data_in_S(data_in_S),
    .done_M(done_M),
    .done_S(done_S)
  );

  always #5 clk = ~clk;

  initial begin
    
    $monitor("time=%0t CPOL=%b CPHA=%b data_M=%h data_S=%h done_M=%b done_S=%b data_in_M=%h data_in_S=%h",
             $time, CPOL,CPHA,data_M, data_S, done_M, done_S, data_in_M, data_in_S);
    $dumpfile("SPI.vcd");
    $dumpvars(0, SPI_tb);

    clk    = 0;
    data_M = 8'hAF;  
    data_S = 8'hBB; 

    // Mode 0: CPOL=0 CPHA=0 
    areset=1; CPOL=0; CPHA=0; #15 areset=0; #250;

    // Mode 1: CPOL=0 CPHA=1 
    areset=1; CPOL=0; CPHA=1; #15 areset=0; #250;

    // Mode 2: CPOL=1 CPHA=0 
    areset=1; CPOL=1; CPHA=0; #15 areset=0; #250;

    // Mode 3: CPOL=1 CPHA=1 
    areset=1; CPOL=1; CPHA=1; #15 areset=0; #250;

    $finish;
  end

endmodule
