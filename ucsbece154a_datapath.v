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
 logic [31:0] PCNext, PCPlus4, PCTarget;
 logic [31:0] ImmExt;
 logic [31:0] SrcA, SrcB;
 logic [31:0] Result;
 // next PC logic
 flopr #(32)    pcreg(clk, reset, PCNext, pc_o);
 adder          pcadd4(pc_o, 32'd4, PCPlus4);
 adder          pcaddbranch(pc_o, ImmExt, PCTarget);
 mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc_i, PCNext);
 // register file logic
 regfile        rf(clk, RegWrite_i, instr_i[19:15], instr_i[24:20], instr_i[11:7], Result, SrcA, WriteData);
 extend         ext(instr_i[31:7], ImmSrc_i, ImmExt);
 // ALU logic
 mux2 #(32)     srcbmux(writedata_o, ImmExt, ALUSrc_i, SrcB);
 alu            alu(SrcA, SrcB, ALUControl_i, aluresult_o, zero_o);
 mux3 #(32)     resultmux(aluresult_o, readdata_i, PCPlus4,ResultSrc_i, Result);
endmodule