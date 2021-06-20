module lab5_Imm_gen(
input [31:0] instruction,
output reg [31:0] imm
);
always@(*)
begin
case(instruction[6:0])
    7'b0010011:imm<={{20{instruction[31]}},instruction[31:20]};//I type
    7'b0000011:imm<={{20{instruction[31]}},instruction[31:20]};//ld
    7'b0100011:imm<={{20{instruction[31]}},instruction[31:25],instruction[11:7]};//sd
    7'b1100011:imm<={{20{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8]};//beq
    7'b1101111:imm<={{12{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21]};//jal
endcase
end

endmodule