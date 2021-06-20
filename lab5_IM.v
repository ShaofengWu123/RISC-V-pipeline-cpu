module lab5_IM(
input clk,
input [7:0] read_address,
output [31:0] instruction
);
dist_mem_gen_0 ins_mem
 (
    .a(read_address),
    .clk(clk),
    .we(0),
    .spo(instruction)
);

endmodule