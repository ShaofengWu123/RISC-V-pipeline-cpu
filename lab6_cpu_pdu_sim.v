`timescale 1ns / 1ps
module lab6_cpu_pdu_sim();
reg clk;
reg rst;
reg [7:0] m_rf_addr;
wire [31:0] rf_data;
wire [31:0] m_data;
wire [31:0] pc; 
wire [31:0] ctrl;
wire [31:0] io_dout;
wire io_we;
wire [7:0] io_addr;
wire [4:0] out;

reg [7:0] m_rf_addr1;
wire [31:0] rf_data1;
wire [31:0] m_data1;
wire [31:0] pc1; 
wire [31:0] ctrl1;
wire [31:0] io_dout1;
wire io_we1;
wire [7:0] io_addr1;
wire [4:0] out1;

lab5_cpu_pl_predict cputest(
.clk(clk),
.rst(rst),
.m_rf_addr(m_rf_addr),   
.rf_data(rf_data),    
.m_data(m_data),
.pc(pc),
.ctrl(ctrl),
.io_din(32'b0),
.io_dout(io_dout),
.io_we(io_we),
.io_addr(io_addr)
);

lab5_cpu_pl cputest1(
.clk(clk),
.rst(rst),
.m_rf_addr(m_rf_addr1),   
.rf_data(rf_data1),    
.m_data(m_data1),
.pc(pc1),
.ctrl(ctrl1),
.io_din(32'b0),
.io_dout(io_dout1),
.io_we(io_we1),
.io_addr(io_addr1)
);

/*lab5_top top(
.clk(clk),
.rst(rst),
.run(1),
.valid(1),
.in(4'b1),
.out0(out)
);*/

initial
begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial 
begin
    rst = 1;
end

initial
begin
    m_rf_addr = 0;
end

/*initial 
begin
    #10 rst = 0;m_rf_addr =1;//read x1
    #80 m_rf_addr =2;
    #50 m_rf_addr =3;
    #50 m_rf_addr = 20;
    #50 $finish;
end
*/
/*for ld-use file
initial
begin
    #10 rst = 0;m_rf_addr =7;//read x7
    #60 m_rf_addr = 8;
    #10 m_rf_addr = 9;
    #20 m_rf_addr = 15;
    #40 m_rf_addr = 10;
    #20 m_rf_addr = 12;
    #10 m_rf_addr =2;
    #20 m_rf_addr =3;
    #10 m_rf_addr =4;
    #20 m_rf_addr = 6;
    #40 m_rf_addr = 1;
    #100 $finish;
end
*/
//for file provided by teacher
initial
begin
    #10 rst = 0;m_rf_addr =1;m_rf_addr1 =1;
    /*#10 m_rf_addr = 5;
    #10 m_rf_addr = 2;//read 0x0008
    #10 m_rf_addr = 6;
    #40 m_rf_addr = 2;//read 0x0008
    #10 m_rf_addr =7;
    #20 m_rf_addr =8;
    #10 m_rf_addr =9;
    #10 m_rf_addr = 2;//read 0x0008
    #20 m_rf_addr = 10;
    #10 m_rf_addr = 2;//read 0x0008*/
    #6000 $finish;
end

endmodule

