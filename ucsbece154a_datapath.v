// ucsbece154a_datapath.v
// All Rights Reserved
// Copyright (c) 2023 UCSB ECE
// Distribution Prohibited


module ucsbece154a_datapath (
    input               clk, reset,
    input               RegWrite_i,
    input         [2:0] ImmSrc_i,
    input               ALUSrc_i,
    input               PCSrc_i,
    input         [1:0] ResultSrc_i,
    input         [2:0] ALUControl_i,
    output              zero_o,
    output reg   [31:0] pc_o,
    input        [31:0] instr_i,
    output wire  [31:0] aluresult_o, writedata_o,
    input        [31:0] readdata_i
);

    `include "ucsbece154a_defines.vh"
    /// Your code here
    // Use name "rf" for a register file module so testbench file work properly (or modify testbench file) 
    wire [31:0] PCNext, PCPlus4, PCTarget;
    wire [31:0] pc_o_temp;
    wire [31:0] ImmExt;
    wire [31:0] SrcA, SrcB;
    wire [31:0] Result;

    // next PC logic
    flopr #(32) pcreg(clk, reset, PCNext, pc_o_temp);
    adder pcadd4(pc_o, 32'd4, PCPlus4);
    adder pcaddbranch(pc_o, ImmExt, PCTarget);
    mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc_i, PCNext);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_o <= 32'b0; // 或根据需求重置
        end else begin
            pc_o <= pc_o_temp; // 将临时值赋给 pc_o
        end
    end

    // register file logic
    regfile rf(
        .clk(clk),
        .we3(RegWrite_i),
        .a1(instr_i[19:15]),
        .a2(instr_i[24:20]),
        .a3(instr_i[11:7]),
        .wd3(Result),
        .rd1(SrcA),
        .rd2(writedata_o)
    );
    extend ext(instr_i[31:7], ImmSrc_i, ImmExt);

    // ALU logic
    mux2 #(32) srcbmux(writedata_o, ImmExt, ALUSrc_i, SrcB);
    alu alu(SrcA, SrcB, ALUControl_i, aluresult_o, zero_o);
    mux3 #(32) resultmux(aluresult_o, readdata_i, PCPlus4, ResultSrc_i, Result);
endmodule

module alu(
    input   [31:0]  a, b,
    input   [2:0]   f,
    output  reg [31:0] result,
    output  reg zero
);

    wire [32:0] sum;

    assign sum = {1'b0, a} + (f == 3'b001 ? ~{1'b0, b} + 1'b1 : {1'b0, b});

    always @(*) begin
        
        case(f)
            3'b000: begin
                result = sum[31:0];
            end
            3'b001: begin
                result = sum[31:0];
            end
            3'b010: begin
                result = a & b;
            end
            3'b011: begin
                result = a | b;
            end
            3'b101: begin
                result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            end
            default: begin
                result = 32'b0;
            end
        endcase

        assign zero = (result == 32'b0) ? 1'b1 : 1'b0;
    end
endmodule


module adder(
    input [31:0] a, b,
    output [31:0] y
);
    assign y = a + b;
endmodule

// module regfile (
//     input clk,
//     input we3,
//     input [4:0] a1, a2, a3,  // 注意Verilog中为[4:0]而不是[5:0]
//     input [31:0] wd3,
//     output [31:0] rd1, rd2
// );
//     reg [31:0] rf[31:0];
//     // 三端口寄存器文件
//     // A1和A2端口用于组合读（读取rd1和rd2），A3端口用于写入
//     // 寄存器0硬连为0
//     always @(posedge clk) begin
//         if (we3) rf[a3] <= wd3;
//     end
//     assign rd1 = (a1 != 0) ? rf[a1] : 32'b0;
//     assign rd2 = (a2 != 0) ? rf[a2] : 32'b0;
// endmodule

module regfile (
    input clk,
    input we3,           // Write enable
    input [4:0] a1, a2, a3, // Address inputs
    input [31:0] wd3,   // Write data input
    output reg [31:0] rd1, rd2 // Read data outputs
);
    // 定义32个32位寄存器
    reg [31:0] rf[31:0];
    reg [31:0] zero;

    // 读寄存器
    always @(*) begin
        rd1 = (a1 != 5'b0) ? rf[a1] : 32'b0; // a1为0时，rd1返回0
        rd2 = (a2 != 5'b0) ? rf[a2] : 32'b0; // a2为0时，rd2返回0
    end

    // 写寄存器
    always @(posedge clk) begin
        if (we3 && (a3 != 5'b0)) rf[a3] <= wd3; // a3为0时不写入
    end

    // 在初始化时，可以将特定寄存器赋值，或者在仿真中添加初始值
    initial begin
        rf[0] = 32'b0; // zero寄存器初始化为0
        // 其他寄存器可以初始化为任意值，如果需要的话
    end
endmodule

module flopr #(parameter WIDTH = 32) (
    input clk, reset,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 0;
        else
            q <= d;
    end
endmodule

module mux2 #(parameter WIDTH = 8) (
    input [WIDTH-1:0] d0, d1,
    input s,
    output [WIDTH-1:0] y
);
    assign y = s ? d1 : d0;
endmodule

module mux3 #(parameter WIDTH = 8) (
    input [WIDTH-1:0] d0, d1, d2,
    input [1:0] s,
    output reg [WIDTH-1:0] y
);
    always @(*) begin
        case (s)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            default: y = d0;
        endcase
    end
endmodule

module extend (
    input [24:0] instr,  // instr的长度改为与输入位匹配
    input [2:0] immsrc,
    output reg [31:0] immext
);
    always @(*) begin
        case (immsrc)
            // I-type
            3'b000: immext = {{20{instr[24]}}, instr[24:13]};
            // S-type (stores)
            3'b001: immext = {{20{instr[24]}}, instr[24:18], instr[4:0]};
            // B-type (branches)
            3'b010: immext = {{20{instr[24]}}, instr[0], instr[23:18], instr[4:1], 1'b0};
            // J-type (jal)
            3'b011: immext = {{12{instr[24]}}, instr[19:12], instr[20], instr[23:21], 1'b0};
            default: immext = 32'bx; // undefined
        endcase
    end
endmodule