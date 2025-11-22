module four_to_sixteen_decoder (
	input En,
	input wire [3:0] A,
	output reg [15:0] Y = 16'b0
);
	always@(*)
		if (En = '1') 
			begin
			integer idx = 0;
			for ( j = 0; j < 4 ; j = j + 1)
					idx = idx + A[j] * (2**(j));
			B[idx] = '1';
			end	
endmodule
