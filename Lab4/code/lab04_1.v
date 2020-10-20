`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/20 16:29:23
// Design Name: 
// Module Name: lab04_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//debounce
module debounce (pb_debounced, pb, clk);
    output pb_debounced;
    input pb;
    input clk;

reg [3:0] shift_reg;

always @(posedge clk)
   begin
      shift_reg[3:1] <= shift_reg[2:0];
      shift_reg[0] <= pb;
   end
assign pb_debounced = ((shift_reg == 4'b1111)? 1'b1: 1'b0);
endmodule

// one-pulse gnerator
module onepulse (pb_debounced, clk, pb_1pulse);
    input pb_debounced;
    input clk;
    output pb_1pulse;
    reg pb_1pulse;
    reg pb_debouced_delay;
    
    always @(posedge clk) begin
        if(pb_debounced == 1'b1 & pb_debouced_delay == 1'b0)
            pb_1pulse <= 1'b1;
        else
            pb_1pulse <= 1'b0;
         
         pb_debouced_delay <= pb_debounced;
        end 
endmodule

//16-bit clock divider
module clock_divider (clk_div, clk);
    input clk;
    output clk_div;
    parameter n = 20;
    reg [n-1:0] num =0;
    wire [n-1: 0] next_num;
    
    always @(posedge clk) begin
        num = next_num;
    end
    
    assign next_num = num+1;
    assign clk_div = num[n-1];
endmodule


module lab04_1(clk,rst, en, dir, DIGIT, DISPLAY, max, min);
    input clk,rst, en, dir;
    output reg [3:0] DIGIT;
    output reg [6:0] DISPLAY;
    output max, min;
    wire rst_de, en_de, dir_de;
    wire rst_one, en_one, dir_one;
    reg dir_st, en_st ;
    reg [7:0] value;
    wire dir_nst, en_nst;
    wire [3:0] BCD0, BCD1, BCD2, BCD3;
    
    
   // clock-divider 
 clock_divider #(24) clk__24(.clk_div(clk_24), .clk(clk));
 clock_divider #(15) clk__25(.clk_div(clk_15), .clk(clk));
 
   
    //pass to debounce
debounce rst_deb (.pb_debounced(rst_de),.pb(rst),.clk(clk));
debounce en_deb (.pb_debounced(en_de),.pb(en),.clk(clk));
debounce dir_deb (.pb_debounced(dir_de),.pb(dir),.clk(clk));

   // pass to onepulse  
onepulse rst__one (.pb_debounced(rst_de), .clk(clk), .pb_1pulse(rst_one));
onepulse en__one (.pb_debounced(en_de), .clk(clk), .pb_1pulse(en_one));
onepulse dir__one (.pb_debounced(dir_de), .clk(clk), .pb_1pulse(dir_one));

 // toggle sdir state and enable state
assign dir_nst = (dir_one) ? ~dir_st: dir_st;
assign en_nst = (dir_one) ? ~en_st: en_st;


always @(posedge rst_de, posedge clk_24) begin
    if(rst_de == 0) begin
        en_st <= 0;
        dir_st <= 1;
    end
    else begin
        en_st <= en_nst;
        dir_st <= dir_nst;
    end
end

   //  counter
always @(posedge rst_de, posedge clk_15) begin
    if(rst_de == 0) begin
        value <= 0;
    end
    else begin
        if(en_st == 0) begin
            value <= value;
        end
        else begin
            if(dir_st == 1) begin
                value <= (value == 99)? 99: value +1;
                end
            else begin
                value <= (value == 0)? 0: value -1;
            end
        end
    end
end 

//always @(posedge clk_15) begin
//    case (DIGIT)
//        4'b1110: begin
//            value = BCD1;
//            DIGIT = 4'b1101;
//        end
//         4'b1110: begin
//            value =  BCD2;
//            DIGIT = 4'B1011;
//        end
//         4'b1110: begin
//            value = BCD3;
//            DIGIT = 4'b0111;   
//        end 
//         4'b1110: begin
//            value = BCD0;
//            DIGIT = 4'b1110;
//        end
//        default : begin
//            value = BCD0;
//            DIGIT = 4'b1110;
//        end
//    endcase
//end

//always @* begin
//    case (value)
//        4'd0: DISPLAY = 7'b1000000;
//        4'd1: DISPLAY = 7'b1111001;
//        4'd2: DISPLAY = 7'b0100100;
//        4'd3: DISPLAY = 7'b0110000;
//        4'd4: DISPLAY = 7'b0011001;
//        4'd5: DISPLAY = 7'b0010010;
//        4'd6: DISPLAY = 7'b0000010;
//        4'd7: DISPLAY = 7'b1111000;
//        4'd8: DISPLAY = 7'b0000000;
//        4'd9: DISPLAY = 7'b0010000;
//        default: DISPLAY = 7'b1111111;
//    endcase
//end
















   
    
    
    
    
   
endmodule
