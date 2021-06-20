`timescale 1ns / 1ps
//this module is a dynamic branch predictor
//store branch instruction PC and last branch result to predict next decision if the branch instruction is encountered again
module lab6_brpredict(
input clk,
input rst,
input [31:0] PC,//for searching if there is a record

input [31:0] PCD,
input [31:0] pc_target,
input Branch,//for determining if a new record should be written

input branch_taken,//for updating record

output reg branch_predict,//for PC source determination, and also deals with hazard where branch is taken and if/id regs are flushed since next instruction is fetched by default
output reg [31:0] branch_target
);
reg [1:0] cnt;//stores the last available space in the array to indicate update place
reg [31:0] pc [3:0];//only supports a total of 4 branch instructions pc and their target,last result stored
reg [31:0] target [3:0];
reg last_res [3:0];

wire new_we;//indicate that new record should be written

wire [1:0] update_pos;
wire old_update;//indicate old record should be updated


always@(posedge clk)
begin
    if(rst)
    begin
        cnt <= 2'b00;
        pc[0] <= 32'b0;  
        pc[1] <= 32'b0;  
        pc[2] <= 32'b0;  
        pc[3] <= 32'b0;  
        last_res[0] <= 1'b0;
        last_res[1] <= 1'b0;
        last_res[2] <= 1'b0;
        last_res[3] <= 1'b0;
    end
    else if(Branch&&(!(PCD==pc[0]))&&(!(PCD==pc[1]))&&(!(PCD==pc[2]))&&(!(PCD==pc[3])))
    begin
        pc[cnt] <= PCD;
        target[cnt] <= pc_target;
        last_res[cnt] <= branch_taken;
        cnt <= cnt + 2'b01;
    end
    else if(Branch&&((PCD==pc[0])||(PCD==pc[1])||(PCD==pc[2])||(PCD==pc[3])))
    begin
        last_res[((PCD==pc[3])?2'b11:((PCD==pc[2])?2'b10:((PCD==pc[1])?2'b01:2'b00)))] <= branch_taken;
    end
    else
    begin
        ;
    end
end

assign new_we = Branch&&(!(PCD==pc[0]))&&(!(PCD==pc[1]))&&(!(PCD==pc[2]))&&(!(PCD==pc[3]));
assign old_update = Branch&&((PCD==pc[0])||(PCD==pc[1])||(PCD==pc[2])||(PCD==pc[3]));
assign update_pos = (PCD==pc[3])?2'b11:((PCD==pc[2])?2'b10:((PCD==pc[1])?2'b01:2'b00));


always@(*)
begin
    case (PC)
        pc[0]: branch_predict =  last_res[0];
        pc[1]: branch_predict =  last_res[1];
        pc[2]: branch_predict =  last_res[2];
        pc[3]: branch_predict =  last_res[3];
        default: branch_predict = 1'b0;//default not taken
    endcase
end

always@(*)
begin
    case (PC)
        pc[0]: branch_target =  target[0];
        pc[1]: branch_target =  target[1];
        pc[2]: branch_target =  target[2];
        pc[3]: branch_target =  target[3];
        default: branch_target = 32'b0;//default not taken
    endcase
end

endmodule
