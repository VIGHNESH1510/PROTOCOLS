`include "APB_master.v"
`include "APB_slave.v"
module top_module #(parameter d_w=8,a_w=8)(
  input PCLK,PRESETn,READ_WRITE,transfer,
  input [d_w-1:0] apb_write_data,
  input [a_w-1:0] apb_write_add,apb_read_add,
  output [d_w-1:0] apb_read_data_out);
wire [d_w-1:0]PWDATA,PRDATA;
wire [a_w-1:0]PADDR;
wire PWRITE,PENABLE,PSELx,PREADY;
  
APB_master ins1(
  .PCLK(PCLK),
  .PRESETn(PRESETn),
  .transfer(transfer),
  .READ_WRITE(READ_WRITE),
  .PREADY(PREADY),
  .PRDATA(PRDATA),
  .apb_write_add(apb_write_add),
  .apb_read_add(apb_read_add),
  .apb_write_data(apb_write_data),
  .PADDR(PADDR),
  .PWDATA(PWDATA),
  .apb_read_data_out(apb_read_data_out),
  .PWRITE(PWRITE),
  .PSELx(PSELx),
  .PENABLE(PENABLE));

APB_slave ins2(
   .PCLK(PCLK),
   .PRESETn(PRESETn),
   .PWRITE(PWRITE),
   .PSELx(PSELx),
   .PENABLE(PENABLE),
   .PWDATA(PWDATA),
   .PADDR(PADDR),
   .PRDATA(PRDATA),
   .PREADY(PREADY));

endmodule
