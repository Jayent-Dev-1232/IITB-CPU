module register (
    input  wire       clk,
    input  wire       write_en,
    input  wire [5:0] in_bus,
    output reg  [5:0] A
);

    always @(posedge clk) begin
        if (write_en)
            A <= in_bus;   // use non-blocking assignment for registers
    end

endmodule


module six_bit_adder (
    input wire [5:0] a,
    input wire [5:0] b,
    output wire [5:0] sum
);
    assign sum = a + b;
endmodule

module pc_update_logic(
	input wire [5:0] A0, A1,
	output wire [5:0] Y0, Y1
	);
	six_bit_adder f1(.a(A0), .b(6'b000001), .sum(Y0));
	six_bit_adder f2(.a(Y0), .b(A1), .sum(Y1));
endmodule


module program_counter(
    input wire [5:0] A0,A1,
    input wire clk,c2,c3,
    output wire [5:0] Y
);

	wire [5:0] B0, B1;
   wire [5:0] B;
	pc_update_logic ul (.A0(A0), .A1(A1), .Y0(B0), .Y1(B1));
	assign B = (c2 == 1'b1) ? B0 : B1 ;
	register regr (.clk(clk), .write_en(c3), .in_bus(B), .A(Y));

endmodule
