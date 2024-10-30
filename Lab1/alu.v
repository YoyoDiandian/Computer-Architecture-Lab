module alu(
    input  [31:0] a, b,
    input  [2:0]  f,
    output reg [31:0] result,
    output reg zero,             
    output reg overflow,
    output reg carry,
    output reg negative
);

wire [32:0] sum;

assign sum = {1'b0, a} + (f == 3'b001 ? ~{1'b0, b} + 1'b1 : {1'b0, b});

always @(*) begin
    overflow = 1'b0;
    
    case(f)
        3'b000: begin
            carry = sum[32];
            result = sum[31:0];
            overflow = (a[31] == b[31]) && (result[31] != a[31]);
        end
        3'b001: begin
            result = sum[31:0];
            carry = (a >= b) ? 1'b1 : 1'b0;
            overflow = (a[31] != b[31]) && (result[31] != a[31]);
        end
        3'b010: begin
            result = a & b;
            carry = 1'b0;
        end
        3'b011: begin
            result = a | b;
            carry = 1'b0;
        end
        3'b101: begin
            result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            carry = 1'b0;
        end
        default: begin
            result = 32'b0;
            carry = 1'b0;
        end
    endcase

    zero = (result == 32'b0) ? 1'b1 : 1'b0;
    negative = result[31];
end
endmodule
