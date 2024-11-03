module test (
    input clk,
    output dout
);
    `include "defines.vh"
    assign sub = subalu;
    assign dout = clk;
endmodule
