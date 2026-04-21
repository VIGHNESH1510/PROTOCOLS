 module tx_baut_gen #(parameter data_width=8)(input tx_clk,tx_arst,output reg tx_tick);
integer tx_clk_freq =10_00_0000;
integer baud_rate = 9600;
integer clk_count = tx_clk_freq/baud_rate;
integer tx_count;
always @(posedge tx_clk or negedge tx_arst)
begin
  if(!tx_arst)
  begin
    tx_count <=0;
    tx_tick <=0;
  end
  else
  begin
    if(tx_count >= clk_count-1)
    begin
      tx_tick <=1;
      tx_count <= 0;
    end
    else begin
      tx_tick <=0;
      tx_count <= tx_count +1;
    end
  end
end
endmodule
