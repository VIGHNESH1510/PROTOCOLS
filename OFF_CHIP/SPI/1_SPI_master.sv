module master(input clk,areset,MISO,CPOL,CPHA,
              input [7:0]data_M,
              output reg MOSI,SCLK,CS,done_M,
              output reg [7:0] data_in_M);
  
 localparam [1:0] IDLE=0, START=1, DATA=2 , STOP =3;
  reg [1:0] state,next;
  reg SCLK_r;
  reg sampling,shifting;
  wire pos_edge,neg_edge;
  reg [7:0]shift_out_M,shift_in_M,count ;
 
  //clock generation
  
  always @(posedge clk or posedge areset)
    begin
      if(areset) begin
        SCLK <= CPOL;
        SCLK_r <= CPOL;
      end
      else begin
        if(state == DATA)
          begin
            SCLK <= ~SCLK;
            SCLK_r <= SCLK;
          end
      end
    end
  
  
  assign pos_edge = SCLK  & ~SCLK_r;
  assign neg_edge = ~SCLK & SCLK_r;

  
  always @(*) begin
    case({CPOL,CPHA})
      0: begin
        sampling = pos_edge;
        shifting = neg_edge;
      end
      1: begin
        sampling = neg_edge;
        shifting = pos_edge;
      end
      2: begin
        sampling = neg_edge;
        shifting = pos_edge;
      end
      3: begin
        sampling = pos_edge;
        shifting = neg_edge;
      end
    endcase
  end 
  
  
  always @(posedge clk or posedge areset) begin
    if(areset) begin
      state <= IDLE;
    end
    else begin
      state <= next;
    end
  end
  
  always @(*) begin
    case(state)
      IDLE: next = START;
      START: next =  DATA;
      DATA: next = (count==8) ? STOP: DATA;
      STOP: next = IDLE ;
    endcase
  end
  
  always @(posedge clk or posedge areset) 
    begin
    if (areset) begin
      shift_out_M <= 0;
      shift_in_M  <= 0;
      count       <= 0;
      CS          <= 1;
      done_M      <= 0;
      data_in_M   <= 0;
      MOSI        <= 0;
    end
    
    else begin
      
    case(state)
      
      IDLE: begin
        shift_out_M <= 0;
        shift_in_M <=0;
        count <=0;
        CS <=1;
        done_M <=0;
        data_in_M <= 0;
        
      end
      
      START: begin
        CS <=0;
        count <=0;
        MOSI <= data_M[7];
        shift_out_M <= {data_M[6:0], 1'b0};
      end
      
      
      DATA: begin
       
            if(shifting) begin
              MOSI <= shift_out_M[7];
              shift_out_M <= shift_out_M <<1;
               count <= count+1;
            end
        
              if(sampling) begin
                shift_in_M <= {shift_in_M[6:0],MISO};
              end
      end
      
      STOP: begin
        count <=0;
        CS<=1;
        done_M <=1;
        data_in_M <= shift_in_M;
      end
      
      endcase
      
    end
  end
 
endmodule
