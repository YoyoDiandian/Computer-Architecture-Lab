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
    output wire   [31:0] pc_o,
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
    flopr #(32) pcreg(clk, reset, PCNext, pc_o);
    adder pcadd4(pc_o, 32'd4, PCPlus4);
    adder pcaddbranch(pc_o, ImmExt, PCTarget);
    mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc_i, PCNext);

    // always @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         pc_o <= 32'b0; // 或根据需求重置
    //     end else begin
    //         pc_o <= pc_o_temp; // 将临时值赋给 pc_o
    //     end
    // end

    // register file logic
    regfile rf(
        .clk(clk),
        .we3(RegWrite_i),
        .input1(instr_i[19:15]),
        .input2(instr_i[24:20]),
        .input3(instr_i[11:7]),
        .wd3(Result),
        .rd1(SrcA),
        .rd2(writedata_o)
    );
    extend ext(instr_i[31:7], ImmSrc_i, ImmExt);

    // ALU logic
    mux2 #(32) srcbmux(writedata_o, ImmExt, ALUSrc_i, SrcB);
    ucsbece154a_alu alu(SrcA, SrcB, ALUControl_i, aluresult_o, zero_o);
    mux3 #(32) resultmux(aluresult_o, readdata_i, PCPlus4, ResultSrc_i, Result);
endmodule


module adder(
    input [31:0] a, b,
    output [31:0] y
);
    assign y = a + b;
endmodule

module regfile (
    input clk,
    input we3,           // Write enable
    input [4:0] input1, input2, input3, // Address inputs
    input [31:0] wd3,   // Write data input
    output wire [31:0] rd1, rd2 // Read data outputs
);
    reg [31:0] rf [0:31]; // Register file array

    wire [31:0] zero, ra, sp, gp, tp, t0, t1, t2;
    wire [31:0] s0, s1, a0, a1, a2, a3, a4, a5, a6, a7;
    wire [31:0] s2, s3, s4, s5, s6, s7, s8, s9, s10, s11;
    wire [31:0] t3, t4, t5, t6;

    // initialize register 0 to always be 0
    initial rf[0] = 0;

    // Write operation
    always @(posedge clk) begin
        if (we3) begin
            rf[input3] <= wd3;
        end
    end

    // Read operation
    assign rd1 = (input1 != 0) ? rf[input1] : 0;
    assign rd2 = (input2 != 0) ? rf[input2] : 0;

    // Define outputs for each register
    assign zero = rf[0];
    assign ra = rf[1];
    assign sp = rf[2];
    assign gp = rf[3];
    assign tp = rf[4];
    assign t0 = rf[5];
    assign t1 = rf[6];
    assign t2 = rf[7];
    assign s0 = rf[8];
    assign s1 = rf[9];
    assign a0 = rf[10];
    assign a1 = rf[11];
    assign a2 = rf[12];
    assign a3 = rf[13];
    assign a4 = rf[14];
    assign a5 = rf[15];
    assign a6 = rf[16];
    assign a7 = rf[17];
    assign s2 = rf[18];
    assign s3 = rf[19];
    assign s4 = rf[20];
    assign s5 = rf[21];
    assign s6 = rf[22];
    assign s7 = rf[23];
    assign s8 = rf[24];
    assign s9 = rf[25];
    assign s10 = rf[26];
    assign s11 = rf[27];
    assign t3 = rf[28];
    assign t4 = rf[29];
    assign t5 = rf[30];
    assign t6 = rf[31];
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