module tb_alu;

    // ALU inputs and outputs
    reg [31:0] a, b;
    reg [2:0] f;
    wire [31:0] result;
    wire zero, overflow, carry, negative;

    // Instantiate the ALU module
    alu uut (
        .f(f),
        .a(a),
        .b(b),
        .result(result),
        .zero(zero),
        .overflow(overflow),
        .carry(carry),
        .negative(negative)
    );

    // Declare a register to hold test vectors from the file
    reg [115:0] testvector [11:0];  // Adjust the size according to the file
    integer i;
    reg [31:0] result_outcome;
    reg zero_outcome, overflow_outcome, carry_outcome, negative_outcome;

    initial begin
        // Read the .tv file into testvector array
        // $readmemh("C:/Mac/Home/Documents/Study/Junior_A/Introduction to Computer Architecture/Lab/Lab 1/alu2.tv", testvector);
        $readmemh("alu2.tv", testvector);

        // Apply each test vector to the ALU
        for (i = 0; i < 12; i = i + 1) begin
            {f, a, b} = testvector[i][114:48];
            result_outcome  =   testvector[i][47:16];
            zero_outcome    =   testvector[i][12];
            overflow_outcome=   testvector[i][8];
            carry_outcome   =   testvector[i][4];
            negative_outcome=   testvector[i][0];
            #10;  // Wait for ALU to process the inputs


            if  (result_outcome == result && zero_outcome == zero && 
                overflow_outcome == overflow && carry_outcome == carry 
                && negative_outcome == negative) begin
                    $display("Test %0d pass!", i);
                end
            else begin
                $display("Test %0d error!", i);
            end

        end
    end
endmodule

