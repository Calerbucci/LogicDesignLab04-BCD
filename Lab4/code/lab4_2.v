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
            4'd11: DISPLAY = 7'b1111110;
            default: DISPLAY = 7'b1111111;
  endcase    
end    
    
endmodule

module BCD(in,out);
input [15:0] in;
output [15:0] out;
reg[15:0] out_temp;
reg[15:0] in_temp;

assign out[15:12] = (in[15:12]/10 >0) ? 11 : in[15:12] % 10 ;
assign out[11:8] = (in[11:8]/10 >0) ? 11 : in[11:8] % 10 ;
assign out[7:4] = (in[7:4]/10 > 0) ? 11 : in[7:4] % 10 ;
assign out[3:0] = (in[3:0]/10 > 0) ? 11 : in[3:0] % 10 ;

//always@(*) begin
//    if(in_temp[15:12]/10 >0) begin
//         out_temp[15:12] = 9;
//     end
//    else begin
//        out_temp[15:12] =  in_temp[15:12] % 10 ;
//    end
//    if(in_temp[11:8]/10 >0) begin
//         out_temp[11:8] = 9;
//     end
//    else  begin
//         out_temp[11:8] =  in_temp[11:8] % 10 ;
//    end
//    if(in_temp[7:4]/10 >0) begin
//          out_temp[7:4] = 9;
//    end
//    else begin
//          out_temp[7:4] =  in_temp[7:4] % 10 ;
//     end
//    if(in_temp[3:0]/10 >0) begin
//        out_temp[3:0] = 9;
//        end
//    else begin
//         out_temp[3:0] =  in_temp[3:0] % 10 ;
//    end
//    if(in_temp[15:12] == 11 || in_temp[11:8] ==11 || in_temp[7:4] ==11 ||in_temp[3:0] == 11) begin
//         out_temp[15:12]=11;
//         out_temp[11:8]=11;
//         out_temp[7:4]=11;
//         out_temp[3:0]=11; 
//    end
//end

//assign out = out_temp;



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

parameter n = 25;
reg  [n-1:0] num;
wire [n-1:0] next_num;

always @(posedge clk) begin  
    num <= next_num;
end

assign  next_num = num + 1;
assign  clk_div = num[n-1];  
     
endmodule

module lab4_2(clk,rst,en,record, display_1, display_2,DIGIT,DISPLAY);
input en;
input rst;
input clk;
input record;
input display_1;
input display_2;
output [3:0] DIGIT;
output [6:0] DISPLAY;

wire en_one, dir_one, record_one;
wire  en_de, dir_de, record_de;
wire clk_25, clk_23;
reg dir_state, en_state, record_state;
reg dir_state_next, en_state_next, record_state_next, next_flag;
reg [15:0] BCD_in;
wire[15:0] BCD_out;
reg max_temp;
reg min_temp;
reg [7:0] value;
reg [7:0] value2;
wire [7:0] value_temp;
wire [7:0] value2_temp;
reg flag;
reg [7:0] display1_val1=0,display1_val2=0; 
reg [7:0] display2_val1=0,display2_val2=0; 
// clock divider
clock_divider #(.n(23)) clk25(.clk(clk),.clk_div(clk_25));
clock_divider #(.n(23)) clk23(.clk(clk),.clk_div(clk_23));
//  debounce
debounce en_debounce(.clk(clk),.pb(en),.pb_debounced(en_de));
debounce dir_debounce(.clk(clk),.pb(record),.pb_debounced(record_de));

// one_pulse
one_pulse en_1pulse(.clk(clk),.pb_debounced(en_de),.pb_1pulse(en_one));
one_pulse dir_1pulse(.clk(clk),.pb_debounced(record_de),.pb_1pulse(record_one));

//  button state
always @(posedge en_one, posedge rst)begin
  if(rst)begin
    en_state_next = 0;
  end
  else begin
    en_state_next = ~en_state;
  end
end

//always @(posedge dir_one, posedge rst)begin
//  if(rst)begin
//    dir_state_next = 1;
//  end
//  else begin
//    dir_state_next = ~dir_state;
//  end
//end

//always @(posedge record_one, posedge rst)begin
//  if(rst)begin
//    record_state_next = 0;
//  end
//  else begin
//    record_state_next = ~record_state;
//  end
//end

// inital condition
//always @(posedge clk_23, posedge rst) begin
//    if (rst) begin
//        en_state <= 1'b0;
//        dir_state <= 1'b1;
//    end 
//    else begin
//        en_state <= en_state_next;
//        dir_state <= dir_state_next;
//    end
//end

always @(posedge clk_23, posedge rst) begin
    if (rst) begin
        en_state <= 1'b0;
        record_state <= 1'b0;
        flag <=1;
    end 
    else begin
        en_state <= en_state_next;
        record_state <= record_state_next;
        flag <= next_flag;
    end
end

// counter
always @(posedge clk_25, posedge rst) begin
    
    if (rst) begin
        value <= 0;
        value2<=0;
        end     
    else begin
        if (en_state==1'b0) 
            value <= value;
        else begin
           if(value == 99) begin
                value2 <= value2+1;
                value <= 0;
           end
           else begin
                value <= value +1;
           end
           if((value2%10 == 0) && (value2/10 == 2)) begin
                value <=0;
           end
//           if(record_one) begin
//                if(flag) begin
//                    display1_val1 = value;
//                    display1_val2 = value2;
//                    flag = 0;
//                end
//                else if(flag == 0) begin
//                     display2_val1 = value;
//                     display2_val2 = value2;
//                     flag = 1;
//                end
//           end
        end
    end
end
always @(posedge record_one) begin
    next_flag=1;
    if (flag) begin
         display2_val1 <= value;
         display2_val2 <= value2;
         next_flag <= 0;
      end
     else if(flag == 0) begin
             display1_val1 <= value;
             display1_val2 <= value2;
           
       end
  end

 // switch direction
//always @(posedge clk_23, posedge rst) begin
//    if (rst)
//        switch_dir <= 4'd11;
//    else if (dir_state == 1)
//        switch_dir <= 4'd11;
//    else
//        switch_dir <= 4'd10;
//end

// display the error if display_1 and display_2 is on

//always@(*) begin
//    if(display_1 && display_2) begin
//        value = 10;
//        value2 =10;
//    end
//end

// BCD
//assign BCD_in[3:0] = (display_1)?display1_val1 %10: value % 10;
//assign BCD_in[7:4] = (display_1)?display1_val1 /10: value / 10;
//assign BCD_in[11:8] =(display_1)?display1_val2 %10: value2 %10;
//assign BCD_in[15:12] = (display_1)?display1_val2 /10:value2/10;
assign value_temp =value;
assign value2_temp = value2;

always@(*) begin
    if(display_1 && display_2) begin
        BCD_in[3:0] = 11;
        BCD_in[7:4] = 11;
        BCD_in[11:8] = 11;
        BCD_in[15:12] =11;
    end
    else if(display_1) begin
        BCD_in[3:0] = display1_val1 %10;
        BCD_in[7:4] = display1_val1 /10;
        BCD_in[11:8] = display1_val2 %10;
        BCD_in[15:12] =display1_val2 /10;
    end
    else if(display_2) begin
        BCD_in[3:0] = display2_val1 %10;
        BCD_in[7:4] = display2_val1 /10;
        BCD_in[11:8] = display2_val2 %10;
        BCD_in[15:12] =display2_val2 /10;
    end
    else begin
        BCD_in[3:0] = value_temp %10;
        BCD_in[7:4] = value_temp /10;
        BCD_in[11:8] = value2_temp %10;
        BCD_in[15:12] =value2_temp /10;
    end
end

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