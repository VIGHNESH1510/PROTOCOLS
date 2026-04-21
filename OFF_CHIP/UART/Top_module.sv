`include "Trx.sv"
`include "tx_baud_gen.sv"
`include "rx.sv"
`include "RX_baud_gen.sv"

module top_module #(parameter data_width =8)(
  input tx_clk,rx_clk,rx_en,tx_en,tx_arst,rx_arst,
  input [data_width-1:0] data,
  output busy,done,parity_error,
  output [data_width-1:0]data_out);
  
  wire tx_tick,rx_tick,tx_dout;
  
   transmitter dut1(
     .tx_clk(tx _clk),
     .tx_arst(tx_arst),
     .tx_tick(tx_tick),
     .tx_en(tx_en),
     .data(data),
     .tx_dout(tx_dout),
     .busy(busy));
    
   tx_baut_gen dut2(
     .tx_clk(tx_clk),
     .tx_arst(tx_arst),
     .tx_tick(tx_tick));
      
   rx_baut_gen dut3(
     .rx_clk(rx_clk),
     .rx_arst(rx_arst),
     .rx_tick(rx_tick));
        
  receiver dut4(
    .rx_clk(rx_clk),
    .rx_arst(rx_arst),
    .rx_tick(rx_tick),
    .rx_en(rx_en),
    .rx_data(tx_dout),
    .parity_error(parity_error),
    .done(done),
    .data_out(data_out));
  
endmodule
