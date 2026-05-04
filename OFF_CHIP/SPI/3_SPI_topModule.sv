`include "SPI_master.sv"
`include "SPI_slave.sv"
module top_module(input clk, areset, CPOL, CPHA, 
                  input [7:0] data_M , data_S, 
                  output [7:0] data_in_M, data_in_S,
                  output done_M, done_S);
  
  wire MOSI, MISO , SCLK, CS, SDI, SDO;
  
  master ins1( .clk(clk),
              .areset(areset),
              .MISO(SDO),
              .CPOL(CPOL),
              .CPHA(CPHA),
              .data_M(data_M),
              .MOSI(MOSI),
              .SCLK(SCLK),
              .CS(CS),
              .done_M(done_M),
              .data_in_M(data_in_M));
  
  slave ins2(.CPOL(CPOL),
             .CPHA(CPHA),
             .SCLK(SCLK),
             .areset(areset),
             .clk(clk),
             .SDI(MOSI),
             .CS(CS),
             .data_S(data_S),
             .SDO(SDO),
             .done_S(done_S),
             .data_in_S(data_in_S));
  
endmodule
