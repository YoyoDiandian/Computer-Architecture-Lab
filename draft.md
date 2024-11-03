module regfile(input logic clk,
        input logic we3,
        input logic [5:0] a1, a2, a3,
        input logic [31:0] wd3,
        output logic [31:0] rd1, rd2);
        logic [31:0] rf[31:0];
        // three ported register file
        // read two ports combinationally (A1/RD1, A2/RD2)
        // write third port on rising edge of clock (A3/WD3/WE3)
        // register 0 hardwired to 0
        always_ff @(posedge clk)
        if (we3) rf[a3] <= wd3;
        assign rd1 = (a1 != 0) ? rf[a1] : 0;
        assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module flopr #(parameter WIDTH = 8)
 (input logic clk, reset,
 input logic [WIDTH−1:0] d,
 output logic [WIDTH−1:0] q);
 always_ff @(posedge clk, posedge reset)
 if (reset) q <= 0;
 else q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
 (input logic [WIDTH−1:0] d0, d1,
 input logic s,
 output logic [WIDTH−1:0] y);
 assign y = s ? d1 : d0;
endmodule

module mux3 #(parameter WIDTH = 8)
 (input logic [WIDTH−1:0] d0, d1, d2,
 input logic [1:0] s,
 output logic [WIDTH−1:0] y);
 assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule

module extend(input logic [31:7] instr,
 input logic [1:0] immsrc,
 output logic [31:0] immext);
 always_comb
 case(immsrc)
 // I−type
 2'b00: immext = {{20{instr[31]}}, instr[31:20]};
 // S−type (stores)
 2'b01: immext = {{20{instr[31]}}, instr[31:25], 
instr[11:7]};
 // B−type (branches)
 2'b10: immext = {{20{instr[31]}}, instr[7], 
instr[30:25], instr[11:8], 1’b0}; 
 // J−type (jal)
 2'b11: immext = {{12{instr[31]}}, instr[19:12], 
instr[20], instr[30:21], 1’b0};
 default: immext = 32'bx; // undefined
 endcase
endmodule

module datapath(input logic clk, reset,
 input logic [1:0] ResultSrc,
input logic PCSrc, ALUSrc,
input logic RegWrite,
input logic [1:0] ImmSrc,
input logic [2:0] ALUControl,
output logic Zero,
output logic [31:0] PC,
input logic [31:0] Instr,
output logic [31:0] ALUResult, WriteData,
input logic [31:0] ReadData);
 logic [31:0] PCNext, PCPlus4, PCTarget;
 logic [31:0] ImmExt;
 logic [31:0] SrcA, SrcB;
 logic [31:0] Result;
 // next PC logic
 flopr #(32) pcreg(clk, reset, PCNext, PC);
 adder pcadd4(PC, 32'd4, PCPlus4);
 adder pcaddbranch(PC, ImmExt, PCTarget);
 mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
 // register file logic
 regfile rf(clk, RegWrite, Instr[19:15], Instr[24:20],
 Instr[11:7], Result, SrcA, WriteData);
 extend ext(Instr[31:7], ImmSrc, ImmExt);
 // ALU logic
 mux2 #(32) srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
 alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
 mux3 #(32) resultmux(ALUResult, ReadData, PCPlus4,
ResultSrc, Result);
endmodule


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

    wire [31:0] PCNext, PCPlus4, PCTarget;
    wire [31:0] ImmExt;
    wire [31:0] SrcA, SrcB;
    wire [31:0] Result;

    // next PC logic
    flopr #(32) pcreg(clk, reset, PCNext, pc_o);
    adder pcadd4(pc_o, 32'd4, PCPlus4);
    adder pcaddbranch(pc_o, ImmExt, PCTarget);
    mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc_i, PCNext);

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