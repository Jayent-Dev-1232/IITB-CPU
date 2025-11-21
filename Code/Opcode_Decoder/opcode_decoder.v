module opcode_decoder{
	input wire [7:0] A,
	output reg [26:0] Y = 26'b0
);
	wire [15:0] B;
	four_to_sixteen_decoder(.En(1'b1), .A(A[7:4]), .Y(B[15:0]));
	two_to_four_decoder(.En(B[1]), .A(A[1:0]), .Y(Y[4:1]));
	one_to_two_decoder (.En(B[12[, .A(A[0]), .Y(Y[16:15]);
	two_to_four_decoder(.En(B[15]), .A(A[1:0]), .Y(Y[22:19]);
	assign Y[0] = B[0];
	assign Y[5:14] = B[2:11];
	assign Y[17:18] = B[13:14];
			
	endmodule
				
			