`timescale 1ns / 1ps
module lab5_ALU_control(
input [2:0] funct3,
input funct7,
input [2:0] ALUOp,
input ALUSrc,//use to identify R, I type
output reg [2:0] alu_control
);
always@(*)
begin
    if(ALUOp==3'b111)//this means control doesnt know what op, op depends on funct7,funct3. For R, I  type
    begin
        if(ALUSrc==0)//R type
        begin
            case(funct3)
                3'b000:
                begin
                    if(funct7==0)
                    begin
                        alu_control <= 3'b000;//R type add
                    end
                   else
                    begin
                        alu_control <= 3'b001;//R type sub
                    end
                end
                //other instructions, to do
            endcase
        end
        else//I type
            begin
                case(funct3)
                    3'b000://addi
                        begin
                            alu_control<=3'b000;
                        end
                endcase
            end
    end
    
    else//this means control know what op
    begin
        alu_control <= ALUOp;
    end
    end
endmodule
