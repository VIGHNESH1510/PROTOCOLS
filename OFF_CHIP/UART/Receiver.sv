module receiver #(parameter data_width = 8)(
  input  rx_clk, rx_arst, rx_tick, rx_en,
  input  rx_data,
  output parity_error, done,
  output [data_width-1:0] data_out
);
  localparam [2:0] IDLE=0, START=1, DATA=2, PARITY=3, STOP=4;
  localparam [3:0] HALF=4'd7, FULL=4'd15;

  reg [2:0] state, next_s;
  reg [3:0] sub_count, bit_count;
  reg [data_width-1:0] r_data;
  reg parity_ok, parity_err_r, done_r;

  // State register
  always @(posedge rx_clk or negedge rx_arst)
    if (!rx_arst) 
      state <= IDLE;
    else          
      state <= next_s;

  // Next-state logic
  always @(*) begin
    next_s = state;
    case (state)
      IDLE: begin  
        if (rx_en && !rx_data) 
        next_s = START;
      end
      START: begin
        if (rx_tick && sub_count == HALF && rx_data==1)
          next_s=IDLE;
        else 
          next_s=(sub_count == FULL)?DATA:START;
      end
      DATA: begin
        if (rx_tick && sub_count==FULL && bit_count == data_width)
         next_s = PARITY;
      end
      PARITY: begin 
        if (rx_tick && sub_count == FULL) 
          next_s = STOP;
      end
      STOP: begin
        if (rx_tick && sub_count == FULL) 
          next_s = IDLE;
      end
      default: next_s = IDLE;
    endcase
  end

  // Datapath
  always @(posedge rx_clk or negedge rx_arst) begin
    if (!rx_arst) begin
      sub_count<= 0;  
      bit_count <= 0;
      r_data <= 0;  
      parity_ok <= 0;
      parity_err_r<= 0; 
      done_r<= 0;
    end else begin
      done_r <= 0;
      case (state)
        IDLE: begin 
          sub_count<= 0; 
          bit_count<= 0; 
          parity_err_r <= 0; 
        end

        START: begin 
          if (rx_tick)
            sub_count <= (sub_count == FULL) ? 4'd0 : sub_count + 1;
        end

        DATA: begin 
          if (rx_tick) begin
            if (sub_count == HALF)
              r_data <= {rx_data, r_data[data_width-1:1]};
          if (sub_count == FULL) begin
           
            bit_count <= bit_count + 1; 
            sub_count <= 0;
          end 
            else 
              sub_count <= sub_count + 1;
        end
        end

        PARITY: begin 
          if (rx_tick) begin
            if (sub_count == HALF) 
            parity_ok <= (rx_data == (^r_data)); 
          if (sub_count == FULL) begin 
            sub_count <= 0;
          end 
            else 
              sub_count <= sub_count + 1;
        end
        end

        STOP: begin 
          if (rx_tick) begin
          if (sub_count == FULL) begin
            parity_err_r <= !parity_ok;  
            done_r <= 1;
            sub_count <= 0;
          end 
            else 
              sub_count <= sub_count + 1;
        end
        end

        default: begin
          sub_count <= 0; 
          bit_count <= 0; 
        end
      endcase
    end
  end

  assign parity_error = parity_err_r;
  assign data_out = r_data;
  assign done = done_r;
endmodule
