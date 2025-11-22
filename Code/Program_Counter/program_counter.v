module program_counter(
	input [5:0] A,
	input c3,
	output [5:0] Y
);
	always@(*)
	begin
	if (c3 == '1')
		Y = A + 1'b1;
	else
		Y = A;
	end
endmodule