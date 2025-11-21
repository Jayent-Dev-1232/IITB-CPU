module one_to_two_decoder (
	input En,
	input wire A,
	output reg [1:0] Y = 2'b0
);
	always@(*)
		if (En = '1')
			begin
			integer idx = 0;
			for ( j = 0; j < 1 ; j = j + 1)
					idx = idx + A[j] * (2**(j));
			B[idx] = '1';
			end		
endmodule