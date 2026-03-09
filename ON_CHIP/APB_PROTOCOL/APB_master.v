module APB_master #(parameter d_w=8,a_w=8)(
  input PCLK,PRESETn,transfer,READ_WRITE,PREADY,
  input [d_w-1:0]PRDATA,
  input [a_w-1:0] apb_write_add,apb_read_add,
  input [d_w-1:0] apb_write_data,
  output reg [a_w-1:0]PADDR,
  output reg [d_w-1:0]PWDATA,
  output reg [d_w-1:0]apb_read_data_out,
  output reg PWRITE,PSELx,PENABLE);

localparam[1:0] IDLE=2'd0, SETUP=2'd1, ACCESS=2'd2;
//reg [a_w-1:0] mem[d_w-1:0];
reg [1:0]state,next;

// state assignment
always @(posedge PCLK or negedge PRESETn)
begin
  if(!PRESETn)
  begin
    state <= IDLE;
 //   apb_read_data_out <= 0;
  end
  else
  begin
    state <= next;
   // if(PSELx && PENABLE && READ_WRITE && PREADY)
     // apb_read_data_out <= PRDATA;
  end
end

// next assignment
always @(*)
begin

case (state)
  IDLE: 
  begin

    if(transfer)
      next = SETUP;
    else
      next = IDLE;
  end

  SETUP:
  begin
    next = ACCESS;
  end

  ACCESS:
  begin
    if(PREADY && transfer)
      next = SETUP;
    else
    next = PREADY? IDLE: ACCESS;
  end

  default:
  begin
    next = IDLE;
  end
endcase
end

always @(posedge PCLK or negedge PRESETn)
begin
  if(!PRESETn)
  begin
      PSELx  <= 0;
      PENABLE<= 0;
      PWRITE <= 0;
      PADDR  <= 0;
      PWDATA <= 0;
        //apb_read_data_out <= 0;
    end
    else
    begin
      case(state)
        IDLE:
        begin
            PSELx <= 0;
            PENABLE <= 0;
        end

        SETUP:
        begin
            PSELx <= 1;
            PENABLE <= 0;
            PWRITE <= ~READ_WRITE;

            if(READ_WRITE)
                PADDR <= apb_read_add;
            else
            begin
                PADDR <= apb_write_add;
                PWDATA <= apb_write_data;
            end
        end

        ACCESS:
        begin
            PENABLE <= 1;

            if(PREADY && READ_WRITE)
                apb_read_data_out <= PRDATA;
        end

        endcase
    end
end
endmodule
