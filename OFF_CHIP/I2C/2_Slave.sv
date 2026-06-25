module I2C_slave #(parameter d_w = 8, ID = 1)
  (input  sys_clk,
   input  reset,
   input  [d_w-1:0] S_DATA,
   inout  logic SDA,
   input  SCL,
   output reg [d_w-1:0] S_D_OUT);

  localparam [3:0] IDLE       = 0,
                   START      = 1,
                   ADDR_CHECK = 2,
                   RW         = 3,
                   ACK_A      = 4,
                   DATA       = 5,
                   ACK_D      = 6,
                   STOP       = 7,
                   END        = 8;

  reg [3:0] state;
  reg       SDA_r;
  reg [6:0] ADD_ID;
  reg [7:0] S_DATA_reg;
  reg [2:0] count;
  reg       rw_bit;
  reg       skip_first;   

  assign SDA = SDA_r ? 1'b0 : 1'bz;

  // Edge detectors 
  reg SCL_prev, SDA_prev;
  always @(posedge sys_clk) begin
    SCL_prev <= SCL;
    SDA_prev <= SDA;
  end

  wire SCL_posedge = ( SCL && !SCL_prev);
  wire SCL_negedge = (!SCL &&  SCL_prev);
  wire START_cond  = ( SCL && !SDA &&  SDA_prev);
  wire STOP_cond   = ( SCL &&  SDA && !SDA_prev);

  // FSM 
  always @(posedge sys_clk) begin
    if (reset) begin
      state      <= IDLE;
      SDA_r      <= 0;
      count      <= 0;
      rw_bit     <= 0;
      S_DATA_reg <= 0;
      ADD_ID     <= ID[6:0];
      skip_first <= 0;
    end
    else begin
      case (state)

        IDLE: begin
          SDA_r      <= 0;
          count      <= 0;
          skip_first <= 0;
          ADD_ID     <= ID[6:0];
          if (SCL && SDA)
            state <= START;
        end

        // Detect START_cond (SDA falls while SCL high).
        // Go directly to ADDR_CHECK and set skip_first so the
        // posedge of SCL that's still ongoing gets discarded.
        START: begin
          SDA_r <= 0;
          if (START_cond) begin
            state      <= ADDR_CHECK;
            count      <= 0;
            ADD_ID     <= ID[6:0];
            skip_first <= 1;
          end
          if (STOP_cond)
            state <= IDLE;
        end

        // skip_first discards the SCL posedge that was already
        // in progress when we entered from START.
        // After that, sample one address bit per SCL_posedge.
        ADDR_CHECK: begin
          SDA_r <= 0;
          if (SCL_posedge) begin
            if (skip_first)
              skip_first <= 0;
            else begin
              if (SDA == ADD_ID[6]) begin
                ADD_ID <= {ADD_ID[5:0], 1'b0};
                if (count == 6) begin
                  state <= RW;
                  count <= 0;
                end
                else
                  count <= count + 1;
              end
              else
                state <= END;
            end
          end
        end

        RW: begin
          SDA_r <= 0;
          if (SCL_posedge) begin
            rw_bit     <= SDA;
            S_DATA_reg <= S_DATA;
            state      <= ACK_A;
          end
        end

       
        ACK_A: begin
          SDA_r <= 1;
          if (SCL_negedge)
            state <= DATA;
        end

        DATA: begin
          if (rw_bit) begin
            // READ: slave drives on SCL_negedge, master samples on posedge
           if (SCL_negedge) begin
             $display("DRIVE count=%0d bit=%0b S_DATA_reg=%b",
                count, S_DATA_reg[7], S_DATA_reg);
    SDA_r <= ~S_DATA_reg[7];
    S_DATA_reg <= {S_DATA_reg[6:0],1'b0};

    if (count == 7) begin
        count <= 0;
        state <= ACK_D;
    end
    else
        count <= count + 1;
end
          end
          else begin
            // WRITE: master drives, slave samples on SCL_posedge
            SDA_r <= 0;
            if (SCL_posedge) begin
              S_D_OUT <= {S_D_OUT[6:0], SDA};
              if (count == 7) begin
                count <= 0;
                state <= ACK_D;
              end
              else
                count <= count + 1;
            end
          end
        end

        ACK_D: begin

  
  if (SCL_negedge) begin
    if (!rw_bit)
      SDA_r <= 1;   // WRITE: slave drives ACK (0)
    else
      SDA_r <= 0;   // READ: slave releases SDA for master's NACK
  end

  if (SCL_posedge)
    state <= STOP;

end
        STOP: begin
          SDA_r <= 0;
          if (STOP_cond || SCL_negedge)
            state <= IDLE;
        end

        END: begin
          SDA_r <= 0;
          state <= IDLE;
        end

        default: begin
          SDA_r <= 0;
          state <= IDLE;
        end

      endcase
    end
  end

endmodule
