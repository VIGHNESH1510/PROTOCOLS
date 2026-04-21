 module transmitter #(parameter data_width =8)(
   input tx_clk,tx_arst,tx_tick,tx_en,
   input [data_width-1:0]data,
   output tx_dout,
   output busy);

 localparam IDLE=0,START=1,DATA=2,PARITY=3,STOP=4;
 reg [2:0] state,next;
   reg [3:0] tx_count;
   reg [data_width-1:0] shift_data,parity_c;
 reg tx;

 //state logic
 always @(posedge tx_clk or negedge tx_arst)
 begin
   if(!tx_arst) begin
     state <= IDLE;
   end
   else state <= next;
 end

// next state logic
always @(*) begin
  case(state)
    IDLE: begin
      next = tx_en ? START: IDLE;
    end
    START: begin
      next = tx_tick ? DATA: START;
    end
    DATA: begin
      next = (tx_tick && tx_count==data_width-1) ? PARITY : DATA;
    end
    PARITY: begin
      next = tx_tick ? STOP: PARITY;
    end
    STOP: begin
      next = tx_tick ? IDLE : STOP;
      end
      default: begin
        next = IDLE;
      end
  endcase
end

  always @(posedge tx_clk or negedge tx_arst) begin
  if(!tx_arst) begin
    tx_count <= 0;
    shift_data <= 0;
    tx <= 1;
    parity_c <=0;
  end
  else begin
    if(state == IDLE && tx_en) begin
      shift_data <= data;
      tx_count <= 0;
      parity_c <=data;
    end

    if(tx_tick) begin
      case(state)
        START: begin
          tx <= 0;
          tx_count <=0;
        end

        DATA: begin
          tx <= shift_data[0];
          //shift_data <= {1'b0,shift_data[data_width-1:1]};
          shift_data <= shift_data >> 1;
          tx_count <= tx_count + 1;
        end

        PARITY: tx <= ^parity_c;
        STOP:   tx <= 1;
        default: tx <=1;
      endcase
    end
  end
end

assign tx_dout = tx;
   assign busy = (state != IDLE) ;
 endmodule
