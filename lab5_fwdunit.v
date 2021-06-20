`timescale 1ns / 1ps
module lab5_fwdunit(
input [4:0] Rs1d,
input [4:0] Rs2d,
input [4:0] RdM,
input [4:0] RdW,
input idexALUSrc,//avoid that the imm is decoded to a legal Rs2d 
input exmemRegWrite,
input memwbRegWrite,
output [1:0] afwd,
output [1:0] bfwd
);
//this module deals with RAW situation, load-use(inlcuding lw-R and lw-sw) should be dealt with by hazard unit and then by this one
assign afwd = ((Rs1d==RdM&&exmemRegWrite)||(Rs1d==RdW&&memwbRegWrite))?(Rs1d==RdM?2'b01:2'b10):2'b00;//0 for A,1 for Y,2 for MDRorYW,select the nearest result if necessary
assign bfwd = idexALUSrc?2'b11:(((Rs2d==RdM&&exmemRegWrite)||(Rs2d==RdW&&memwbRegWrite))?(Rs2d==RdM?2'b01:2'b10):2'b00);//0 for B, 3 for imm, 1 for Y, 2 for MDRorYW

endmodule
