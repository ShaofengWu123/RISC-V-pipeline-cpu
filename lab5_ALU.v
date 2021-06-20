`timescale 1ns / 1ps
module lab5_ALU(
input [31:0] alusrc1,alusrc2,//operator
input [2:0] alu_control,//oprand,
output reg [31:0] alu_result,//result
output zero//sign zero
 );
 
 always @(*)
 begin
    case(alu_control)
        3'b000: alu_result = alusrc1+alusrc2;
        3'b001: alu_result = alusrc1-alusrc2;
        3'b010: alu_result = alusrc1&alusrc2;
        3'b011: alu_result = alusrc1|alusrc2;
        3'b100: alu_result=  alusrc1^alusrc2;
        default: alu_result = 0; 
    endcase
 end

 assign zero = alu_result? 0:1; 

endmodule
