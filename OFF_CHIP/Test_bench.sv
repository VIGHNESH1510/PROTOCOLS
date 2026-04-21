
`timescale 1ns/1ps
module UART_tb;
  parameter data_width=8;
  reg tx_clk,rx_clk,rx_en,tx_en,tx_arst,rx_arst;
  reg [data_width-1:0] data;
  wire busy,done,parity_error;
  wire [data_width-1:0] data_out;

  top_module uut(
    .tx_clk(tx_clk),
    .rx_clk(rx_clk),
    .rx_en(rx_en),
    .tx_en(tx_en),
    .tx_arst(tx_arst),
    .rx_arst(rx_arst),
    .data(data),
    .busy(busy),
    .done(done),
    .parity_error(parity_error),
    .data_out(data_out));

  always #50  tx_clk=~tx_clk;
  always #20  rx_clk=~rx_clk;

  initial begin
    $dumpfile("UART.vcd"); 
    $dumpvars(0,UART_tb);
    $monitor("time=%0t data=%b busy=%b done=%b data_out= %b",$time,data,busy,done,data_out);
    tx_clk=0; rx_clk=0; tx_en=0; rx_en=1; tx_arst=0; rx_arst=0; data=0;
    #500  tx_arst=1; rx_arst=1;
    #200  data=8'hAF;
    #100  tx_en=1;
    #100  tx_en=0;
    #2_000_000;
    $display("RESULT  : data_out=0x%0h parity_error=%b",data_out,parity_error);
    $display("EXPECTED: data_out=0xAF parity_error=0");
    $display("STATUS  : %s",(data_out===8'hAF && !parity_error)?"PASS":"FAIL");
    $display("time=%0t | DONE | data_out=0x%0h | parity_error=%b",
             $time,data_out,parity_error);
    #1 $finish;
  end
    
endmodule
