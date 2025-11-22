module opcode_decoder(
    input  wire [7:0]  A,
    output wire [26:0] Y
);

    wire [15:0] B;

    four_to_sixteen_decoder f1 (.En(1'b1),.A(A[7:4]),.Y(B));

    two_to_four_decoder f2 (.En(B[1]),.A(A[1:0]),.Y(Y[4:1]));

    one_to_two_decoder f3 (.En(B[12]),.A(A[0]),.Y(Y[16:15]));

    two_to_four_decoder f4 (.En(B[15]),.A(A[1:0]),.Y(Y[22:19]));

    assign Y[0]     = B[0];
    assign Y[5:14]  = B[11:2];
    assign Y[17:18] = B[14:13];

endmodule
