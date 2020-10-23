module _7_SEG(
input clk,
input  [3:0] BCD0,BCD1,BCD2,BCD3,
output reg [3:0] DIGIT,
output reg [6:0] DISPLAY
);

wire clk1;    
    clock_divider #(15) clk_15(.clk(clk),.clk_div(clk15));    
    
reg [3:0] value;
reg [1:0] digit_temp, next_digit;
    
always @(posedge clk15)  begin
    digit_temp <= next_digit;
    case(digit_temp)
        2'b00:    begin
                    value = BCD0;
                    DIGIT = 4'b1110;
                  end
                        
        2'b01:    begin
                    value = BCD1;
                    DIGIT = 4'b1101;
                  end
        2'b10:   begin
                    value = BCD2;
                    DIGIT = 4'b1011;
                  end    
        2'b11: begin
                    value = BCD3;
                    DIGIT = 4'b0111;
                 end         
        endcase                
    end
    
always @* begin
    next_digit = digit_temp +1;
    case(value)
            4'd0: DISPLAY = 7'b0000001;
            4'd1: DISPLAY = 7'b1001111;
            4'd2: DISPLAY = 7'b0010010;
            4'd3: DISPLAY = 7'b0000110;
            4'd4: DISPLAY = 7'b1001100;
            4'd5: DISPLAY = 7'b0100100;
            4'd6: DISPLAY = 7'b0100000;
            4'd7: DISPLAY = 7'b0001111;
            4'd8: DISPLAY = 7'b0000000;
            4'd9: DISPLAY = 7'b0000100;
            4'd11: DISPLAY = 7'b0011101;
            4'd10: DISPLAY = 7'b1100011;
            default: DISPLAY = 7'b1111111;
  endcase    
end    
    
endmodule

module BCD(in,out);
input [15:0] in;
output [15:0] out;

assign out[15:12] = (in[15:12] == 4'd11) ? 4'd11 : 4'd10 ;
assign out[11:8] = (in[11:8] == 4'd11) ? 4'd11 : 4'd10 ;
assign out[7:4] = (in[7:4]/10 > 0) ? 9 : in[7:4] % 10 ;
assign out[3:0] = (in[3:0]/10 > 0) ? 9 : in[3:0] % 10 ;

endmodule

module one_pulse(clk,pb_debounced,pb_1pulse);
input clk;
input pb_debounced;
output pb_1pulse;

wire clk0;   
    clock_divider # (23) clock(.clk(clk),.clk_div(clk0));

reg pb_1pulse;
reg pb_debounced_delay;
    
always @(posedge clk0) begin
    pb_debounced_delay <= pb_debounced;
    if ((pb_debounced) && (!pb_debounced_delay)) pb_1pulse <= 1'b1;
    else pb_1pulse <= 1'b0;
end   
endmodule

module debounce(clk,pb,pb_debounced);
input clk;
input pb;
output pb_debounced;

wire clk1;
    clock_divider #(13) clk_13(.clk(clk),.clk_div(clk1));

reg [3:0] shift_reg;

always @(posedge clk1) begin
    shift_reg[3:1] <= shift_reg[2:0];
    shift_reg[0] <= pb;
end

assign pb_debounced = ((shift_reg == 4'b1111) ? 1'b1 : 1'b0);

endmodule

module clock_divider (clk_div, clk);
input clk;
output clk_div;

parameter width = 25;
reg  [width-1:0] num;
wire [width-1:0] next_num;

always @(posedge clk) begin  
    num <= next_num;
end

assign  next_num = num + 1;
assign  clk_div = num[width-1];  
     
endmodule

module lab4_1(clk,rst,en,dir,DIGIT,DISPLAY,max,min);
input en;
input rst;
input clk;
input dir;
output [3:0] DIGIT;
output [6:0] DISPLAY;
output max;
output min;
wire en_one, dir_one;
wire  en_de, dir_de;
wire clk_25, clk_23;
reg dir_state, en_state;
reg dir_state_next, en_state_next;
wire [15:0] BCD_in, BCD_out;
reg max_temp;
reg min_temp;
reg [7:0] value;
reg [3:0] switch_dir;
// clock divider
clock_divider #(.width(25)) clk25(.clk(clk),.clk_div(clk_25));
clock_divider #(.width(23)) clk23(.clk(clk),.clk_div(clk_23));
//  debounce
debounce en_debounce(.clk(clk),.pb(en),.pb_debounced(en_de));
debounce dir_debounce(.clk(clk),.pb(dir),.pb_debounced(dir_de));

// one_pulse
one_pulse en_1pulse(.clk(clk),.pb_debounced(en_de),.pb_1pulse(en_one));
one_pulse dir_1pulse(.clk(clk),.pb_debounced(dir_de),.pb_1pulse(dir_one));

//  button state


always @(posedge en_one, posedge rst)begin
  if(rst)begin
    en_state_next = 0;
  end
  else begin
    en_state_next = ~en_state;
  end
end

always @(posedge dir_one, posedge rst)begin
  if(rst)begin
    dir_state_next = 1;
  end
  else begin
    dir_state_next = ~dir_state;
  end
end

// inital condition
always @(posedge clk_23, posedge rst) begin
    if (rst) begin
        en_state <= 1'b0;
        dir_state <= 1'b1;
    end 
    else begin
        en_state <= en_state_next;
        dir_state <= dir_state_next;
    end
end


// counter
always @(posedge clk_25, posedge rst) begin
    if (rst) 
        value <= 0;
    else begin
        if (en_state==1'b0) 
            value <= value;
        else begin
            if (dir_state==1'b1) begin
                    if(value == 99) 
                        value <= 99;
                    else
                         value <= value + 1;              
                end
            else begin
                    if (value == 0) 
                        value <= 0;
                    else 
                        value = value -1;               
               end
        end
    end
end

 // switch direction
always @(posedge clk_23, posedge rst) begin
    if (rst)
        switch_dir <= 4'd11;
    else if (dir_state == 1)
        switch_dir <= 4'd11;
    else
        switch_dir <= 4'd10;
end

// BCD
assign BCD_in[3:0] = value % 10;
assign BCD_in[7:4] = value / 10;
assign BCD_in[11:8] = switch_dir;
assign BCD_in[15:12] = switch_dir;

BCD BCD_MODULE(.in(BCD_in),.out(BCD_out));

// Turn LED max and LED min
always @(*)begin
      if(value==99 && dir_state==1 && ~rst)begin
        max_temp =1;
      end
      else begin
        max_temp = 0;
      end
end

always @(*) begin
      if(value==0 && dir_state==0 && ~rst) begin
        min_temp = 1;
      end
      else begin
        min_temp =0;
      end
end

assign max = max_temp;
assign min = min_temp;


_7_SEG dec(.clk(clk),.BCD0(BCD_out[15:12]),.BCD1(BCD_out[11:8]),.BCD2(BCD_out[7:4]),.BCD3(BCD_out[3:0]),.DIGIT(DIGIT),.DISPLAY(DISPLAY));

endmodule