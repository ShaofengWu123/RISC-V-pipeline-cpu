`timescale 1ns / 1ps
module lab5_control(
input [6:0] ins,
output reg Jump,
output reg Branch,
output reg MemRead,
output reg MemtoReg,
output reg [2:0] ALUOp,
output reg MemWrite,
output reg ALUSrc,
output reg RegWrite
);
always@(*)
begin
    case(ins)
        7'b0110011://R
            begin
                Jump=0;
                Branch=0;
                MemRead=0;
                MemtoReg= 0;
                ALUOp=3'b111;//this represents control does not know what op alu should do
                MemWrite=0;
                ALUSrc=0;
                RegWrite=1;
            end
         7'b0010011://It ype
            begin
                Jump=0;
                Branch=0;
                MemRead=0;
                MemtoReg= 0;
                ALUOp=3'b111;
                MemWrite=0;
                ALUSrc=1;
                RegWrite=1;
            end
         7'b0000011://load
            begin
                Jump=0;
                Branch=0;
                MemRead=1;
                MemtoReg= 1;
                ALUOp=3'b000;//add op
                MemWrite=0;
                ALUSrc=1;
                RegWrite=1;
            end
         7'b0100011://store
            begin
                Jump=0;
                Branch=0;
                MemRead=0;
                MemtoReg= 0;
                ALUOp=3'b000;//add op
                MemWrite=1;
                ALUSrc=1;
                RegWrite=0;
            end
         7'b1100011://branch
            begin
                Jump=0;
                Branch=1;
                MemRead=0;
                MemtoReg= 0;
                ALUOp=3'b001;//sub op to compare,actually branch is done in id segment,so this one is no longer useful 
                MemWrite=0;
                ALUSrc=0;
                RegWrite=0;
            end
         7'b1101111://jal,write data is PC+4, not from memory
            begin
                Jump=1;
                Branch=0;
                MemRead=0;
                MemtoReg= 0;
                ALUOp=0;//doesnt matter
                MemWrite=0;
                ALUSrc=0;
                RegWrite=1;
            end
         default:
            begin
                Jump=0;
                Branch=0;
                MemRead=0;
                MemtoReg= 0;
                ALUOp=0;
                MemWrite=0;
                ALUSrc=0;
                RegWrite=0;
            end
    endcase
end

endmodule
