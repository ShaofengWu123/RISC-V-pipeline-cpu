module lab5_Reg(
input [4:0] read_reg1,
input [4:0] read_reg2,
input [4:0] write_reg,
input [31:0] write_data,
output [31:0] read_data1,
output [31:0] read_data2,
input [4:0] m_rf_addr,
output  [31:0] rf_data,
input RegWrite,
input clk,
input rst
);
reg [31:0] regfile [0:31];//regfile, store data 
always@(*)
begin
   regfile[0] <= 32'b0;//RISCV x0=0
end

//asyn read
assign read_data1 = (RegWrite&&(write_reg==read_reg1))?write_data:regfile[read_reg1];//write first
assign read_data2 = (RegWrite&&(write_reg==read_reg2))?write_data:regfile[read_reg2];
assign rf_data = regfile[m_rf_addr];
//syn write
always@(posedge clk)
begin
    if(rst)
    begin
        regfile[0] <= 0;
        regfile[1] <= 0;
    end
    else if(RegWrite)
    begin
        regfile[write_reg] <= write_data; 
    end    
end

endmodule