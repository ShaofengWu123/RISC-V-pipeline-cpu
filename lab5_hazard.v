`timescale 1ns / 1ps
module lab5_hazard(
input idexMemRead,//detect lw
input exmemMemRead,
input idexRegWrite,
input exmemRegWrite,
input [4:0] Rs1,
input [4:0] Rs2,
input [4:0] Rd,//detect collision of reg use
input [4:0] RdM,
input Jump,
input Branch,
input branch_taken,//use to determine stall if/id or not
input ifidbranch_predict,//use to determine flush if/id or not
output ifiden,
output ifidflush,
output idexen,
output idexflush,
output PCen
);
//this module deals with following hazards:
//1.load-use(lw-R,lw-sw), note that lw-sw can be dealt with by forwarding but for simplicity, we do not use that method
//when lw is in EX and R/sw in ID, stall IF and ID for one cycle and flush EX when lw enters MEM
//2.control hazards

//control hazard
//if jal, just flush if/id to insert a bubble
//if beq, and no R-beq risk or lw-beq, flush if/id to insert a bubble
//if beq, R-beq risk,stall one cycle for IF,ID,then forward Y to ID segment to compare result
//if beq, lw-beq risk,stall two cycles for IF,ID,then forward write_data to compare result
//Here we use a simpler way, both stall two cycles, then because regfile is write-first, the write result can be directly used to compare
wire branch_risk;//note that load-use can detect when beq in ID and lw in EX, so no need to implement this
assign branch_risk = ((Branch&&(Rs1==Rd||Rs2==Rd)&&idexRegWrite)||(Branch&&(Rs1==RdM||Rs2==RdM)&&exmemRegWrite)||(Branch&&(Rs1==RdM||Rs2==RdM)&&idexMemRead))?1:0;

//load-use
assign PCen = ((idexMemRead&&(Rs1==Rd||Rs2==Rd))||branch_risk)?0:1;
assign ifiden = ( (idexMemRead&&(Rs1==Rd||Rs2==Rd))||branch_risk)?0:1;//same as PCen, stall together to save current IR
assign ifidflush = (Jump||(branch_taken!=ifidbranch_predict))?1:0;
assign idexen = 1;
assign idexflush = ((idexMemRead&&(Rs1==Rd||Rs2==Rd))||branch_risk)?1:0;//flush id/ex regs to insert a bubble



endmodule
