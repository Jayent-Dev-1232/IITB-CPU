module bit_adder (
    input  wire [7:0] X,
    input  wire [7:0] Y,
    input  wire add_sub,
    output wire [7:0] S,
    output wire overflow,
    output wire carry
);

    wire [7:0] Yxor;
    wire [8:0] C;
    assign C[0] = add_sub;
    assign Yxor = Y ^ {8{add_sub}};

    full_adder fa0 (.a(X[0]), .b(Yxor[0]), .cin(C[0]), .sum(S[0]), .cout(C[1]));
    full_adder fa1 (.a(X[1]), .b(Yxor[1]), .cin(C[1]), .sum(S[1]), .cout(C[2]));
    full_adder fa2 (.a(X[2]), .b(Yxor[2]), .cin(C[2]), .sum(S[2]), .cout(C[3]));
    full_adder fa3 (.a(X[3]), .b(Yxor[3]), .cin(C[3]), .sum(S[3]), .cout(C[4]));
    full_adder fa4 (.a(X[4]), .b(Yxor[4]), .cin(C[4]), .sum(S[4]), .cout(C[5]));
    full_adder fa5 (.a(X[5]), .b(Yxor[5]), .cin(C[5]), .sum(S[5]), .cout(C[6]));
    full_adder fa6 (.a(X[6]), .b(Yxor[6]), .cin(C[6]), .sum(S[6]), .cout(C[7]));
    full_adder fa7 (.a(X[7]), .b(Yxor[7]), .cin(C[7]), .sum(S[7]), .cout(C[8]));

    assign carry = C[8];
    assign overflow = C[7] ^ C[8];

endmodule