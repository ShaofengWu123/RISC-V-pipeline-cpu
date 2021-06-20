`timescale 1ns / 1ps
module lab5_cpu_pl(
input clk,
input rst,
//IO_BUS
output [7:0] io_addr,      //led/seg address
output [31:0] io_dout,     //led/seg data
output io_we,                 //led/seg enable
input [31:0] io_din,      

//Debug_BUS
input [7:0] m_rf_addr,   
output [31:0] rf_data,    
output [31:0] m_data,

//PC/IF/ID regs
output [31:0] pc,

output [31:0] pcd,
output [31:0] ir,
output [31:0] pcin,

//ID/EX regs
output [31:0] pce,
output [31:0] a,
output [31:0] b,

output [31:0] imm_out,

output [4:0] rd,
output reg [31:0] ctrl,

//EX/MEM regs
output [31:0] y,
output [31:0] bm_out,
output [4:0] rdm,
output reg [31:0] ctrlm,

//MEM/WB regs
output [31:0] yw,
output [31:0] mdr,
output [4:0] rdw,
output reg [31:0] ctrlw
);


//define registers and signals, registers are upper-cased, output signals are lower-cased
//forward unit
wire [1:0] afwd;
wire [1:0] bfwd;


//pipeline segment 1: IF
//in this segment, every cycle a instruction is fetched according to pc
wire PCen;//use for stall pipeline
reg [31:0] PCD;
reg [31:0] NPCD;
//note: all pc we use is the same as assembly code, but when we use pc to read from memory, we divide 4(pc starts from 0, this doesnt matter because instruction position is relative and we do not provide support for 
//instructions like auipc that generate data memory address use pc that starts from 0x00003000)
reg [31:0] IR;
wire ifiden;
wire ifidflush;

//pipeline segment 2: ID
//in this segment, register file is read and control signals are generated
reg [31:0] idexIR;//use for determining alusrc2 forward
reg [31:0] PCE;
reg [31:0] NPCE;
reg [31:0] A; 
reg [31:0] B; 
reg [31:0] Imm;
reg [4:0] Rd;
reg [2:0] alu_control_reg;
reg [4:0] Rs1d;
reg [4:0] Rs2d;
wire PCSrc;
wire idexen;
wire idexflush;
wire [31:0] imm;
wire zero;

//control signals
wire Jump;
wire Branch;
wire MemRead;
wire MemtoReg;
wire [2:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
reg branch_taken;
//control regs
reg idexJump;
reg idexBranch;
reg idexMemRead;
reg idexMemtoReg;
reg [2:0] idexALUOp;
reg idexMemWrite;
reg idexALUSrc;
reg idexRegWrite;
//pipeline segment 3: EX
//in this segment, PC+offset is calcualted and R type result/save address/load address/zero is calculated
reg [31:0] Y;//store result of ALU
reg [31:0] BM;
reg [4:0] RdM;
//control regs
reg exmemMemRead;
reg exmemMemtoReg;
reg exmemMemWrite;
reg exmemRegWrite;
//pipeline segment 4: MEM
//in this segment, memory is read/written, ALU result is passed(R tpye), PC is loaded into pc
reg [31:0] MDR;
reg [31:0] YW;
reg [4:0] RdW; 
reg memwbMemtoReg;
reg memwbRegWrite;
//pipeline segment 5: WB
//in this segment, R type result/save result is written back to regfile, since regfile is "write first", instruction in ID can get latest result

//define output signals,some are defined later
assign pcd = PCD;
assign ir=IR;
assign pce = PCE;
assign a = A;
assign b = B;
assign imm_out = Imm;
assign rd = Rd;
assign y = Y;
assign bm_out = BM;
assign rdm = RdM;
assign yw = YW;
assign mdr = MDR;
assign rdw = RdW;



//instancing modules, registers have been defined
//pipeline segment 1: IF
//in this segment, every cycle a instruction is fetched according to pc
//registers, these registers are upper-cased, output signals are lower-cased
//generate NPC
wire [31:0] NPC;
reg [31:0] PC;
assign pc = PC;
//assign NPC = ((zero&&Branch)||Jump)?PC+imm_shift:PC+4;//PC+4 but remember that ins mem next instruction is PC+1,more logic to do
assign NPC = PC+4;
//update PC
always@(posedge clk)
begin
    if(rst)
    begin
        PC<= 8'h00000000;//instruction memory spac,not start from 0x00003000 because actual ip core RAM address start from
    end
    else if(PCen)
    begin
        PC <= (Jump||branch_taken)?PCD+{imm[30:0],1'b0}:NPC;
    end
end
assign pcin = (Jump||branch_taken)?PCD+{imm[30:0],1'b0}:NPC;
//instruction memory instance
wire [31:0] read_address;
wire [31:0] instruction;
assign read_address = {PC[31],PC[31],PC[31:2]};//this means PC/4 for real address
//instruction memory
lab5_IM IM(
.clk(clk),
.read_address(read_address),
.instruction(instruction)
);


//IF/ID flush registers
always@(posedge clk)
begin
    if(rst)
    begin
        PCD<=32'b0;
        IR<=32'b0;
        NPCD<=32'b0;
    end
    else if(ifiden)
    begin
        if(ifidflush)
        begin
            IR <= 32'b0;
            PCD<=32'b0;
            NPCD<=32'b0;
        end
        else
        begin
            PCD <= PC;
            NPCD<= NPC;
            IR <= instruction;
        end
    end
end


//pipeline segment 2: ID
//in this segment, register file is read and control signals are generated
//PC+offset is calcualted using a separated adder instead of ALU, branch taken or not is determined using "="
//control unit generates control signals
//hazard detection unit detects hazards
//imm_gen generates IMM
wire [31:0] write_data;
wire [31:0] read_data1;
wire [31:0] read_data2;
lab5_Reg REG(
.read_reg1(IR[19:15]),
.read_reg2(IR[24:20]),
.write_reg(RdW),
.write_data(write_data),
.read_data1(read_data1),
.read_data2(read_data2),
.m_rf_addr(m_rf_addr[4:0]),
.rf_data(rf_data),
.RegWrite(memwbRegWrite),
.clk(clk),
.rst(rst)
);
//branch unit
always@(*)
begin
    if(Branch)
    begin
        if(IR[14:12]==3'b000)//beq
        begin
            if(read_data1==read_data2)
            begin
                branch_taken = 1;
            end
            else
            begin
                branch_taken = 0;
            end
        end
        else if(IR[14:12]==3'b001)//bne
        begin
            if(read_data1!=read_data2)
            begin
                branch_taken = 1;
            end
            else
            begin
                branch_taken = 0;
            end
        end
        else if(IR[14:12]==3'b100)//blt
        begin
            if(read_data1<read_data2)
            begin
                branch_taken = 1;
            end
            else
            begin
                branch_taken = 0;
            end
        end
        else if(IR[14:12]==3'b101)//bge
        begin
            if(read_data1>read_data2||read_data1==read_data2)
            begin
                branch_taken = 1;
            end
            else
            begin
                branch_taken = 0;
            end
        end
        else
        begin
            branch_taken = 0;
        end
    end
    else
    begin
        branch_taken = 0;
    end
end
//assign branch_taken = ((read_data1==read_data2)&&Branch)?1:0;

//immediate generate
lab5_Imm_gen Imm_gen(
.instruction(IR),
.imm(imm)
);
//control unit
lab5_control Control(
.ins(IR[6:0]),
.Jump(Jump),
.Branch(Branch),
.MemRead(MemRead),
.MemtoReg(MemtoReg),
.ALUOp(ALUOp),
.MemWrite(MemWrite),
.ALUSrc(ALUSrc),
.RegWrite(RegWrite)
);
//ALU control
wire [2:0] alu_control;
lab5_ALU_control ALU_control(
.funct3(IR[14:12]),
.funct7(IR[30]),
.ALUOp(ALUOp),
.ALUSrc(ALUSrc),
.alu_control(alu_control)
);

//these are not used, but have to be defined to generate ctrl signals
wire a_sel;wire b_sel;wire [1:0] wb_sel;
assign wb_sel = Jump?2'b10:(MemtoReg?2'b01:2'b00);//0 for R type, 1 for load(mem and IO), 2 for jump(PC)
assign a_sel = 1'b0;//because branch is done in ID, so A is always from read_data1
assign b_sel = 1'b0;//because branch is done in ID, so B is always from read_data2


//ID/EX flush registers
always@(posedge clk)
begin
    if(rst)
    begin
            PCE<=0;
            NPCE<=0;
            A<=0; 
            B<=0; 
            Imm<=0;
            Rd<=0;
            Rs1d<=0;
            Rs2d<=0;
            //PCSrc;
            //control regs
            idexJump<=0;
            idexBranch<=0;
            idexMemRead<=0;
            idexMemtoReg<=0;
            idexALUOp<=0;
            idexMemWrite<=0;
            idexALUSrc<=0;
            idexRegWrite<=0;
            alu_control_reg <=0;
            idexIR <= 0;
            ctrl <= 32'b0;
    end
    else if(idexen)
    begin
        if(idexflush)
        begin
            PCE<=PCD;
            NPCE<=0;
            A<=0; 
            B<=0; 
            Imm<=0;
            Rd<=0;
            Rs1d<=0;
            Rs2d<=0;
            //PCSrc;
            //control regs
            idexJump<=0;
            idexBranch<=0;
            idexMemRead<=0;
            idexMemtoReg<=0;
            idexALUOp<=0;
            idexMemWrite<=0;
            idexALUSrc<=0;
            idexRegWrite<=0;
            alu_control_reg <=0;
            idexALUSrc <=0;
            idexIR <= 0;
            ctrl <= 32'b0;
        end
        else
        begin
            PCE<=PCD;
            NPCE<=NPCD;
            A<=read_data1; 
            B<=read_data2; 
            Imm<=imm;
            Rd<=IR[11:7];
            Rs1d<=IR[19:15];
            Rs2d<=IR[24:20];
            //PCSrc;
            //control regs
            idexJump<=Jump;
            idexBranch<=Branch;
            idexMemRead<=MemRead;
            idexMemtoReg<=MemtoReg;
            idexALUOp<=ALUOp;
            idexMemWrite<=MemWrite;
            idexALUSrc<=ALUSrc;
            idexRegWrite<=RegWrite;
            alu_control_reg <= alu_control;
            idexALUSrc <= ALUSrc;
            idexIR <= IR;
            ctrl <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,afwd,1'b0,1'b0,bfwd,1'b0,RegWrite,wb_sel,1'b0,1'b0,MemRead,MemWrite,1'b0,1'b0,Jump,Branch,1'b0,1'b0,a_sel,b_sel,1'b0,ALUOp};
        end
    end
end
//pipeline segment 3: EX
//in this segment,  and R type result/save address/load address is calculated
//ALU control

//ALU
reg [31:0] alusrc1;
reg [31:0] alusrc2;
wire [31:0] alu_result;
reg [31:0] bm;
//assign alusrc1 = A;
always@(*)
begin
    case(afwd)
        2'b00:alusrc1 = A;
        2'b01:alusrc1 = Y;
        2'b10:alusrc1 = write_data;
        default:alusrc1 = A;
    endcase
end
//assign alusrc2 =idexALUSrc?Imm:B;
always@(*)
begin
    case(bfwd)
        2'b00:alusrc2 = B;
        2'b01:alusrc2 = Y;
        2'b10:alusrc2 = write_data;
        2'b11:alusrc2 = Imm;
    endcase
end

always@(*)
begin
    case(bfwd)
        2'b00:bm = B;
        2'b01:bm = Y;
        2'b10:bm = write_data;
        2'b11://for sw operation, do not care about I type like addi because it doesnt need BM anymore
            bm = ((Rs2d==RdM&&exmemRegWrite)||(Rs2d==RdW&&memwbRegWrite))?(Rs2d==RdM?Y:write_data):B;
    endcase
end

lab5_ALU ALU(
.alusrc1(alusrc1),
.alusrc2(alusrc2),
.alu_control(alu_control_reg),
.zero(zero),
.alu_result(alu_result)
);

//EX/MEM registers, this part does not need to stall or flush
always@(posedge clk)
begin
    if(rst)
    begin
    Y<=0;
    BM <= 0;
    RdM <= 0;
    exmemMemRead <=0;
    exmemMemtoReg <=0;
    exmemMemWrite <=0;
    exmemRegWrite <=0;
    ctrlm <= 32'b0;
    end
    else
    begin
    Y<=idexJump?NPCE:alu_result;//if jal, write PC+4 back
    BM <= bm;
    RdM <= Rd;
    exmemMemRead <= idexMemRead;
    exmemMemtoReg <= idexMemtoReg;
    exmemMemWrite <= idexMemWrite;
    exmemRegWrite <= idexRegWrite;
    ctrlm <= ctrl;
    end
end


//pipeline segment 4: MEM
//in this segment, memory is read/written, ALU result is passed(R tpye), PC is loaded into pc
wire [31:0] address;
wire [31:0] read_data;
wire [31:0] read_data_mem;
wire [31:0] IO_addr;
assign IO_addr = Y;
assign address = {Y[31],Y[31],Y[31:2]};//this means alu_result/4 for real adress
//data memory
lab5_DM DM(
.clk(clk),
//.MemWrite(MemWrite&(~IO_addr[10])),
.MemWrite(exmemMemWrite&(~IO_addr[10])),//if not I/O address, write into data memory
.write_data_dm(BM),
.address(address),
.read_data(read_data_mem),
.m_data(m_data),//debug_bus
.m_rf_addr(m_rf_addr)//debug_bus
);

//MEM/WB registers, this part does not need to stall or flush
always@(posedge clk)
begin
    if(rst)
    begin
    MDR<=0;
    YW<=0;
    RdW<=0; 
    memwbMemtoReg<=0;
    memwbRegWrite<=0;
    ctrlw <= 32'b0;
    end
    else
    begin
    MDR<=IO_addr[10]?io_din:read_data;
    YW<=Y;
    RdW<=RdM; 
    memwbMemtoReg<=exmemMemtoReg;
    memwbRegWrite<=exmemRegWrite;
    ctrlw <= ctrlm;
    end
end


//pipeline segment 5: WB
//in this segment, R type result/save result is written back to regfile, since regfile is "write first", instruction in ID can get latest result
assign write_data = memwbMemtoReg?MDR:YW;//if load, get data from DM or I/O, here we should consider forward data; else get data from ALU result 


//forward unit
lab5_fwdunit fwdunit(
.Rs1d(Rs1d),
.Rs2d(Rs2d),
.RdM(RdM),
.RdW(RdW),
.idexALUSrc(idexALUSrc),//avoid that the imm is decoded to a legal Rs2d
.exmemRegWrite(exmemRegWrite),
.memwbRegWrite(memwbRegWrite),
.afwd(afwd),
.bfwd(bfwd)
);


//hazard detection unit
lab5_hazard hazard(
.idexMemRead(idexMemRead),
.exmemMemRead(exmemMemRead),
.idexRegWrite(idexRegWrite),
.exmemRegWrite(exmemRegWrite),
.Rs1(IR[19:15]),
.Rs2(IR[24:20]),
.Rd(Rd),
.RdM(RdM),
.Jump(Jump),
.Branch(Branch),
.branch_taken(branch_taken),
.ifiden(ifiden),
.ifidflush(ifidflush),
.idexen(idexen),
.idexflush(idexflush),
.PCen(PCen)
);



//I/O signals 

assign io_addr = Y[7:0];
assign io_dout = BM;
assign io_we = exmemMemWrite&IO_addr[10];//write into I/O regs in MEM segment

endmodule


