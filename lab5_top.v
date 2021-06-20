`timescale 1ns / 1ps
module lab5_top(
input clk,
input rst,
input run,
input step,
input valid,
input [4:0] in,
output [7:0] out0,
output [2:0] an,
output [3:0] seg
);
wire ready;
wire [1:0] check;
wire clk_cpu;
wire [7:0] io_addr;
wire [31:0] io_dout;
wire io_we;
wire [31:0] io_din;
wire [7:0] m_rf_addr;
wire [31:0] rf_data;
wire [31:0] m_data;
wire [31:0] pcin, pc, pcd, pce;
wire [31:0] ir, imm, mdr;
wire [31:0] a, b, y, bm, yw;
wire [4:0]  rd, rdm, rdw;
wire [31:0] ctrl, ctrlm, ctrlw;  

pdu pdu1(
.clk(clk),
.rst(rst),
.run(run), 
.step(step),
.clk_cpu(clk_cpu),
.valid(valid),
.in(in),
.check(check),
.out0(out0),
.an(an),
.seg(seg),
.ready(ready), 
.io_addr(io_addr),
.io_dout(io_dout),
.io_we(io_we),
.io_din(io_din),
.m_rf_addr(m_rf_addr),
.rf_data(rf_data),
.m_data(m_data),
.pc(pc),
.pcin(pcin),
.pcd(pcd),
.pce(pce),
.ir(ir),
.imm(imm),
.mdr(mdr),
.a(a),
.b(b),
.y(y),
.bm(bm),
.yw(yw),
.rd(rd),
.rdm(rdm),
.rdw(rdw),
.ctrl(ctrl),
.ctrlm(ctrlm),
.ctrlw(ctrlw)
);


lab5_cpu_pl_predict cpu(
.clk(clk_cpu),
.rst(rst),
.m_rf_addr(m_rf_addr),//debug bus
.rf_data(rf_data),//debug bus
.m_data(m_data),//debug_bus
.io_din(io_din), 
.io_addr(io_addr),
.io_dout(io_dout),
.io_we(io_we),
.pc(pc),
.pcin(pcin),
.pcd(pcd),
.pce(pce),
.ir(ir),
.imm_out(imm),
.mdr(mdr),
.a(a),
.b(b),
.y(y),
.bm_out(bm),
.yw(yw),
.rd(rd),
.rdm(rdm),
.rdw(rdw),
.ctrl(ctrl),
.ctrlm(ctrlm),
.ctrlw(ctrlw)
);
endmodule