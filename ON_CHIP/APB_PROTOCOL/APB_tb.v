module APb_tb #(parameter d_w=8, a_w=8);
reg PCLK=0,PRESETn,READ_WRITE,transfer;
reg [d_w-1:0] apb_write_data;
reg [a_w-1:0] apb_write_add,apb_read_add;
wire [d_w-1:0] apb_read_data_out;
top_module dut(.PCLK(PCLK),
  .PRESETn(PRESETn),
  .READ_WRITE(READ_WRITE),
  .transfer(transfer),
  .apb_write_data(apb_write_data),
  .apb_write_add(apb_write_add),
  .apb_read_add(apb_read_add),
  .apb_read_data_out(apb_read_data_out)
);

always #5 PCLK = ~PCLK;

task write;
  input [d_w-1:0] data;
  input [a_w-1:0] addr;
  begin
    @(posedge PCLK);
    READ_WRITE =0;
    apb_write_add = addr;
    apb_write_data = data;
    transfer =1;
    @(posedge PCLK);
    @(posedge PCLK);
    $display("time=%0t WRITE ADDR=%d DATA=%d",$time,addr,data);
    @(posedge PCLK);
    transfer =0;
  end
endtask

task read;
input [a_w-1:0]addr;
begin
  @(posedge PCLK);
  READ_WRITE =1;
  apb_read_add =addr;
  transfer = 1;
    @(posedge PCLK);
    @(posedge PCLK);
    //@(posedge PCLK);
  $display("time=%0t READ ADDR=%0d DATA=%0d",$time,addr,apb_read_data_out);
  @(posedge PCLK);
  transfer = 0;
end
endtask


initial 
begin
  $dumpfile("APB.vcd");
  $dumpvars;
PRESETn=0; READ_WRITE=0; transfer=0;
#15;
PRESETn=1;
write($random,8'd0);
write($random,8'd1);
write($random,8'd3);
#25;
read(8'd7);
read(8'd6);
read(8'd0);
read(8'd1);
read(8'd2);
read(8'd3);

#80 $finish;
end
endmodule
