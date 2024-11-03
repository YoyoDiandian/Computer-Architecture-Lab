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
    reg [31:0] ImmExt;
    wire [31:0] SrcA, SrcB;
    reg [31:0] Result;

    // next PC logic
    // flopr #(32) pcreg(clk, reset, PCNext, pc_o);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_o <= 0;
        else
            pc_o <= PCNext;
    end
    assign PCPlus4 = pc_o + 32'd4;
    // adder pcadd4(pc_o, 32'd4, PCPlus4);
    // adder pcaddbranch(pc_o, ImmExt, PCTarget);
    // mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc_i, PCNext);
    wire PCSrc;
    wire jump;
    assign PCTarget = PCSrc ? pc_o + ImmExt : 32'bx;
    assign jump = (ImmSrc_i == 3'b010 & SrcA == SrcB);
    assign PCSrc = jump ? 1 : PCSrc_i;
    assign PCNext = PCSrc ? PCTarget : PCPlus4;

    // register file logic
    reg a1[4:0], a2[4:0];
    ucsbece154a_rf rf (
        .clk(clk),
        .we3_i(RegWrite_i),
        .a1_i(instr_i[6:0] == instr_lui_op || instr_i[6:0] == instr_jal_op ? 5'b1 : instr_i[19:15]),
        .a2_i(instr_i[6:0] == instr_lui_op || instr_i[6:0] == instr_jal_op || instr_i[6:0] == instr_ItypeALU_op ? 5'b1 : instr_i[24:20]),
        .a3_i(instr_i[11:7]),
        .wd3_i(Result),
        .rd1_o(SrcA),
        .rd2_o(writedata_o)
    );

    always @(*) begin
        case (ImmSrc_i)
            // I-type
            3'b000: ImmExt = {{20{instr_i[31]}}, instr_i[31:20]};
            // S-type (stores)
            3'b001: ImmExt = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            // B-type (branches)
            3'b010: ImmExt = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
            // J-type (jal)
            3'b011: ImmExt = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
            default: ImmExt = 32'bx; // undefined
        endcase
    end

    // ALU logic
    // mux2 #(32) srcbmux(writedata_o, ImmExt, ALUSrc_i, SrcB);
    assign SrcB = ALUSrc_i ? ImmExt : writedata_o;
    ucsbece154a_alu alu(SrcA, SrcB, ALUControl_i, aluresult_o, zero_o);
    // mux3 #(32) resultmux(aluresult_o, readdata_i, PCPlus4, ResultSrc_i, Result);

    always @(*) begin
        case (ResultSrc_i)
            2'b00: Result = aluresult_o;
            2'b01: Result = readdata_i;
            2'b10: Result = PCPlus4;
            default: Result = aluresult_o;
        endcase
    end
endmodule

