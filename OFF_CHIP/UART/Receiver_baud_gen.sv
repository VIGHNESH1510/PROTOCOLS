module rx_baut_gen #(parameter data_width=8)(input rx_clk,rx_arst,output reg rx_tick);
integer rx_clk_freq =25_000_000;
integer baud_rate = 9600;
  integer clk_count = rx_clk_freq/(baud_rate*16);
integer rx_count;
  always @(posedge rx_clk or negedge rx_arst)
begin
  if(!rx_arst)
  begin
    rx_count <=0;
    rx_tick <=0;
  end
  else
  begin
    if(rx_count >= clk_count-1)
    begin
      rx_tick <=1;
      rx_count <= 0;
    end
    else begin
      rx_tick <=0;
      rx_count <= rx_count +1;
    end
  end
end
endmodule
