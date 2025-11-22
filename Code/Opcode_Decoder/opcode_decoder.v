module one_to_two_decoder (
    input wire En,
    input wire  A,
    output reg [1:0] Y
);

integer j;
integer idx;

always @(*) begin
    Y = 2'b00;      // clear output
    idx = 0;

    if (En == 1'b1) begin
        case(A)
			 1'b1: Y[1] = 1'b1;
			 1'b0: Y[0] = 1'b1;
			 default : Y = 2'b00;
		  endcase
    end
end
endmodule

module two_to_four_decoder (
    input wire En,
    input wire [1:0] A,
    output reg [3:0] Y
);

integer j;
integer idx;

always @(*) begin
    Y = 4'b0000;      // clear output
    idx = 0;

    if (En == 1'b1) begin
        for (j = 0; j < 2; j = j + 1)
            idx = idx + A[j] * (1 << j);

        Y[idx] = 1'b1;
    end
end
endmodule

module four_to_sixteen_decoder (
    input wire En,
    input wire [3:0] A,
    output reg [15:0] Y
);

integer j;
integer idx;

always @(*) begin
    Y = 16'b0000000000000000;      // clear output
    idx = 0;

    if (En == 1'b1) begin
        for (j = 0; j < 4; j = j + 1)
            idx = idx + A[j] * (1 << j);

        Y[idx] = 1'b1;
    end
end
endmodule


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
    assign Y[14:5]  = B[11:2];
    assign Y[18:17] = B[14:13];	  
	 assign Y[23] = A[3];
	 assign Y[24] = A[2];
	 assign Y[25] = A[1];
	 assign Y[26] = A[0];

endmodule
