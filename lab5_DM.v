module lab5_DM(
input clk,
input MemWrite,
input [31:0] write_data_dm,
input [7:0] address,
output [31:0] read_data,
output [31:0] m_data,//debug_bus
input  [7:0] m_rf_addr//debug_bus
);
dist_mem_gen_1 data_mem
 (
    .clk(clk),
    .a(address),
    .d(write_data_dm),
    .we(MemWrite),
    .spo(read_data),
    .dpra(m_rf_addr),
    .dpo(m_data)
);

endmodule