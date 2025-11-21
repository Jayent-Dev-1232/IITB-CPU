module two_to_four_decoder (
	input En,
	input wire [1:0] A,
	output reg [3:0] Y = 4'b0
);
	always@(*)
		if (En = '1')
			begin
			integer idx = 0;
			for ( j = 0; j < 2 ; j = j + 1)
					idx = idx + A[j] * (2**(j));
			B[idx] = '1';
			end		
endmodule