module slave(input CPOL,CPHA,SCLK,clk,areset,SDI,CS, //SDI slave data_in (MOSI)
             input [7:0]data_S, 
             output reg SDO,done_S, // SDO slave data_Out (MISO)
             output reg [7:0]data_in_S);
  
  reg [7:0]shift_out_s,shift_in_s;
  localparam IDLE=0,START=1, DATA=2, STOP=3;
  reg [1:0] state, next;
  reg [3:0] count;
  reg SCLK_s1, SCLK_s2;
  reg SDI_s1,  SDI_s2;
  reg CS_s1,   CS_s2;
  reg SCLK_r;

  // 2-FF synchroniser for SCLK, SDI, CS
  always @(posedge clk or posedge areset) begin
    if (areset) begin
      SCLK_s1 <= CPOL; SCLK_s2 <= CPOL;
      SDI_s1  <= 0;    SDI_s2  <= 0;
      CS_s1   <= 1;    CS_s2   <= 1;  
    end else begin
      SCLK_s1 <= SCLK;   SCLK_s2 <= SCLK_s1;
      SDI_s1  <= SDI;    SDI_s2  <= SDI_s1;
      CS_s1   <= CS;     CS_s2   <= CS_s1;
    end
  end


  
  always @(posedge clk or posedge areset) begin
    if (areset) SCLK_r <= CPOL;
    else SCLK_r <= SCLK_s2;
  end

  wire sclk_rising  =  SCLK_s2 & ~SCLK_r;
  wire sclk_falling = ~SCLK_s2 &  SCLK_r;

  
  wire sampling = ((CPOL==0 && CPHA==0) || (CPOL==1 && CPHA==1))
                    ? sclk_rising : sclk_falling;

  wire shifting  = ((CPOL==0 && CPHA==0) || (CPOL==1 && CPHA==1))
                    ? sclk_falling : sclk_rising;
  
  always @(posedge clk  or posedge areset) begin
    if(areset) state <= IDLE;
    else state <= next;
  end
  
  always @(*) begin
    case(state)
      IDLE: next = START;
      START: next = !CS_s2 ? DATA : START;
      DATA: next = (count ==8) ? STOP: DATA;
      STOP: next = CS_s2 ? IDLE: STOP;
    endcase
  end
  
  always @(posedge clk or posedge areset) begin
    if(areset) begin
      count <=0;
      SDO <= 0;
      data_in_S <= 0;
      shift_out_s <=0;
      shift_in_s <=0;
      done_S <=0;
      
    end
    else begin
      case(state)
        IDLE: begin
          done_S <= 0;
          SDO <=0;
          shift_in_s <=0;
          shift_out_s <=0;
          data_in_S <= 0;
        end
        
        START: begin
            SDO <= data_S[7];
            shift_out_s <= data_S <<1;
            done_S <=0;
           count <=0;

        end
        
        
        DATA: begin
          
          done_S <=0;
          if(shifting) begin
            SDO <= shift_out_s[7];
            shift_out_s <= shift_out_s <<1;
             count <= count+1;
            end
          if(sampling) begin
            shift_in_s <= {shift_in_s[6:0],SDI_s2};
          end
          
        end
        
        STOP: begin
          data_in_S <= shift_in_s;
          done_S <= 1'b1;
          count <= 0;
        end
        
      endcase
    end
    
  end
  
endmodule
