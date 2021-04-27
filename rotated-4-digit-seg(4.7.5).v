//4 input hex3,hex2,hex1,hex0 đi qua bo MUX 4-1 dau ra la wire hex_in noi voi bo display led BCD
//day dieu khien bo MUX 4-1 la 2 bit MSB q_reg[17,16] cua D_FF
module rotated-4-digit-seg (
    input wire clk,reset,
    input wire [3:0] hex3, hex2, hex1, hex0,
    output reg  [3:0] an,//enable 1-out-of-4 assert low
    output reg [7:0] sseg //led segments
);
//constant declaration
//refreshing rate around 800 Hz(50 MHz/2^16)

localparam  = 18;
//internal signal declaration
reg [N-1:0] q_reg;
wire [N-1:0] q_next;
reg [3:0] hex_in;

//N-bit counter
//register/ D_FF
always @(posedge clk,posedge reset) begin
    if(reset)
    q_reg <= 0;
    else
    q_reg <= q_next;
end

//next-state logic
assign q_next = q_reg +1;

//rotated 4-digit
always @(posedge clk or posedge reset) begin
    if(reset) begin
        hex3 <= 0;
        hex2 <= 4'd1;
        hex1 <= 4'd2;
        hex0 <= 4'd3;
        //reset truong hop ban dau se la 0123
    end
    else if(hex3 == 4'd9) begin // 9 reached
        hex3 <= 0;
        if(hex2 == 4'd9) begin //9 reached
            hex2 <= 0;
            if(hex1 == 4'd9) begin  //9 reached
                hex1 <=0;
                if(hex0 == 4'd9) //9 reached
                    hex0 <= 0;
                else
                hex0 <= hex0 + 1;
            end
            else
            hex1 <= hex1 + 1;
        end
        else
        hex2 <= hex2 + 1;
    end
    else
    hex3 <= hex3 + 1;
end
//VD1: 1234 tuong ung hex3, hex2,hex1,hex0. 4 chu so deu khac 9 nen moi chu so cong them 1 thanh 2345
//VD2: 6789. Do hex0 bang 9 nen sau do 1 chu ky hex0 se bang 0, cac chu so con lai deu nho hon 9 cong them 1 se la 7890



//2 MSBs of counter to control 4-to-1 multiplexing
//and go to generate active-low enable signal
always @(*) begin
    case (q_reg[N-1:N-2])
      2'b00:
      begin
          an = 4'b1110; //0:on 1 led, 1:off other 3 leds
          hex_in = hex0;
      end
      2'b01:
      begin
          an = 4'b1101; //0:on, 1:off
          hex_in = hex1;
      end2'b10:
      begin
          an = 4'b1011; //0:on, 1:off
          hex_in = hex2;
      end2'b11:
      begin
          an = 4'b0111; //0:on, 1:off
          hex_in = hex3;
      end
    endcase  
end



//hex to seven-segment led display BCD-digit
always @(*) begin
    case(hex_in)
    4'd0: sseg[6:0] = 7'b0000001;
    4'd1: sseg[6:0] = 7'b1001111;
    4'd2: sseg[6:0] = 7'b0010010;
    4'd3: sseg[6:0] = 7'b0000110;
    4'd4: sseg[6:0] = 7'b1001100;
    4'd5: sseg[6:0] = 7'b0100100;
    4'd6: sseg[6:0] = 7'b0100000;
    4'd7: sseg[6:0] = 7'b0001111;
    4'd8: sseg[6:0] = 7'b0000000;
    4'd9: sseg[6:0] = 7'b0001000;
    default: sseg[6:0] = 7'b1000000;//dash
    endcase
end
endmodule
