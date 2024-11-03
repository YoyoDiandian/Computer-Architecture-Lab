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
    assign PCTarget = pc_o + ImmExt;
    // adder pcaddbranch(pc_o, ImmExt, PCTarget);
    // mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc_i, PCNext);
    assign PCNext = PCSrc_i ? PCTarget : PCPlus4;

    // register file logic
    ucsbece154a_rf rf(
        .clk(clk),
        .we3_i(RegWrite_i),
        .a1_i(instr_i[19:15]),
        .a2_i(instr_i[24:20]),
        .a3_i(instr_i[11:7]),
        .wd3_i(Result),
        .rd1_o(SrcA),
        .rd2_o(writedata_o)
    );
    // extend ext(instr_i[31:7], ImmSrc_i, ImmExt);

    always @(*) begin
        case (ImmSrc_i)
            // I-type
            3'b000: ImmExt = {{20{instr_i[24]}}, instr_i[24:13]};
            // S-type (stores)
            3'b001: ImmExt = {{20{instr_i[24]}}, instr_i[24:18], instr_i[4:0]};
            // B-type (branches)
            3'b010: ImmExt = {{20{instr_i[24]}}, instr_i[0], instr_i[23:18], instr_i[4:1], 1'b0};
            // J-type (jal)
            3'b011: ImmExt = {{12{instr_i[24]}}, instr_i[19:12], instr_i[20], instr_i[23:21], 1'b0};
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


// module adder(
//     input [31:0] a, b,
//     output [31:0] y
// );
//     assign y = a + b;
// endmodule

// module flopr #(parameter WIDTH = 32) (
//     input clk, reset,
//     input [WIDTH-1:0] d,
//     output reg [WIDTH-1:0] q
// );
//     always @(posedge clk or posedge reset) begin
//         if (reset)
//             q <= 0;
//         else
//             q <= d;
//     end
// endmodule

// module mux2 #(parameter WIDTH = 8) (
//     input [WIDTH-1:0] d0, d1,
//     input s,
//     output [WIDTH-1:0] y
// );
//     assign y = s ? d1 : d0;
// endmodule

// module mux3 #(parameter WIDTH = 8) (
//     input [WIDTH-1:0] d0, d1, d2,
//     input [1:0] s,
//     output reg [WIDTH-1:0] y
// );
//     always @(*) begin
//         case (s)
//             2'b00: y = d0;
//             2'b01: y = d1;
//             2'b10: y = d2;
//             default: y = d0;
//         endcase
//     end
// endmodule

// module extend (
//     input [24:0] instr,  // instr的长度改为与输入位匹配
//     input [2:0] immsrc,
//     output reg [31:0] immext
// );
//     always @(*) begin
//         case (immsrc)
//             // I-type
//             3'b000: immext = {{20{instr[24]}}, instr[24:13]};
//             // S-type (stores)
//             3'b001: immext = {{20{instr[24]}}, instr[24:18], instr[4:0]};
//             // B-type (branches)
//             3'b010: immext = {{20{instr[24]}}, instr[0], instr[23:18], instr[4:1], 1'b0};
//             // J-type (jal)
//             3'b011: immext = {{12{instr[24]}}, instr[19:12], instr[20], instr[23:21], 1'b0};
//             default: immext = 32'bx; // undefined
//         endcase
//     end
// endmodule
