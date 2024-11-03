/*
    ucsbece154a_top_tb.v
    All Rights Reserved
    Copyright (c) 2023 UCSB ECE
    Distribution Prohibited
*/
`timescale 1ns / 1ns

`define SIM
`define ASSERT(CONDITION, MESSAGE) if ((CONDITION)==1'b1); else begin $error($sformatf MESSAGE); end

module ucsbece154a_top_tb ();

// 定义时钟和复位信号
reg clk;
reg reset;

// 设置时钟周期和仿真结束时间
parameter CYCLE = 2;
parameter END_TIME = 200;

/***************************************************/

// 初始化顶层模块
ucsbece154a_top top (
    .clk    (clk),
    .reset  (reset)
);

/***************************************************/

// 定义寄存器输出的 wire
wire [31:0] reg_zero = top.riscv.dp.rf.zero;
wire [31:0] reg_ra   = top.riscv.dp.rf.ra;
wire [31:0] reg_sp   = top.riscv.dp.rf.sp;
wire [31:0] reg_gp   = top.riscv.dp.rf.gp;
wire [31:0] reg_tp   = top.riscv.dp.rf.tp;
wire [31:0] reg_t0   = top.riscv.dp.rf.t0;
wire [31:0] reg_t1   = top.riscv.dp.rf.t1;
wire [31:0] reg_t2   = top.riscv.dp.rf.t2;
wire [31:0] reg_s0   = top.riscv.dp.rf.s0;
wire [31:0] reg_s1   = top.riscv.dp.rf.s1;
wire [31:0] reg_a0   = top.riscv.dp.rf.a0;
wire [31:0] reg_a1   = top.riscv.dp.rf.a1;
wire [31:0] reg_a2   = top.riscv.dp.rf.a2;
wire [31:0] reg_a3   = top.riscv.dp.rf.a3;
wire [31:0] reg_a4   = top.riscv.dp.rf.a4;
wire [31:0] reg_a5   = top.riscv.dp.rf.a5;
wire [31:0] reg_a6   = top.riscv.dp.rf.a6;
wire [31:0] reg_a7   = top.riscv.dp.rf.a7;
wire [31:0] reg_s2   = top.riscv.dp.rf.s2;
wire [31:0] reg_s3   = top.riscv.dp.rf.s3;
wire [31:0] reg_s4   = top.riscv.dp.rf.s4;
wire [31:0] reg_s5   = top.riscv.dp.rf.s5;
wire [31:0] reg_s6   = top.riscv.dp.rf.s6;
wire [31:0] reg_s7   = top.riscv.dp.rf.s7;
wire [31:0] reg_s8   = top.riscv.dp.rf.s8;
wire [31:0] reg_s9   = top.riscv.dp.rf.s9;
wire [31:0] reg_s10  = top.riscv.dp.rf.s10;
wire [31:0] reg_s11  = top.riscv.dp.rf.s11;
wire [31:0] reg_t3   = top.riscv.dp.rf.t3;
wire [31:0] reg_t4   = top.riscv.dp.rf.t4;
wire [31:0] reg_t5   = top.riscv.dp.rf.t5;
wire [31:0] reg_t6   = top.riscv.dp.rf.t6;

/***************************************************/

// 生成 VCD 波形文件
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, ucsbece154a_top_tb);
end

/***************************************************/

// 初始化状态
initial begin
    clk = 0;
    reset = 1;
end

/***************************************************/

// 生成时钟信号
always begin
    #(CYCLE / 2) clk = ~clk;
end

/***************************************************/

// 测试过程
integer i;
initial begin
    $display("Begin simulation.");

    // 复位信号操作
    @(negedge clk);
    @(negedge clk);
    reset = 0;

    // 测试程序
    for (i = 0; i < 24; i = i + 1)
        @(negedge clk);

    // 断言测试
    // `ASSERT(reg_zero == 32'b0, ("reg_zero incorrect"));
    // `ASSERT(reg_sp == 32'hBEEF000, ("reg_sp incorrect"));
    // `ASSERT(reg_gp == 32'h44, ("reg_gp incorrect"));
    // `ASSERT(reg_tp == 32'h1, ("reg_tp incorrect"));
    // `ASSERT(reg_t0 == 32'hb, ("reg_t0 incorrect"));
    // `ASSERT(reg_t2 == 32'h7, ("reg_t2 incorrect"));
    // `ASSERT(top.dmem.RAM[24] == 32'h7, ("dmem.RAM[24] incorrect"));
    // `ASSERT(top.dmem.RAM[25] == 32'h19, ("dmem.RAM[25] incorrect"));
    // `ASSERT(top.dmem.RAM[26] == 32'hBEEF000, ("dmem.RAM[26] incorrect"));

    // 结束仿真
    $display("End simulation.");
    $stop;
end

/***************************************************/

endmodule

`undef ASSERT