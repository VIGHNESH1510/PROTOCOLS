module APB_slave #(parameter d_w=8,a_w=8)(
  input PCLK,PRESETn,PWRITE,PSELx,PENABLE,
  input [d_w-1:0] PWDATA,
  input [a_w-1:0] PADDR,
  output  [d_w-1:0] PRDATA,
  output reg PREADY);

reg [d_w-1:0] mem[255:0];
assign PRDATA = mem[PADDR];

always @(posedge PCLK or negedge PRESETn)
begin
  if(!PRESETn)
  begin
    PREADY <=0;
  end
  else if(PSELx && PENABLE)
  begin
      if(PWRITE)
      mem[PADDR] <= PWDATA;
   end
  else
    PREADY <=0;
end

endmodule
