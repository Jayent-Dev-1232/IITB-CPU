module six_bit_adder (
    input wire [5:0] a,
    input wire [5:0] b,
    output wire [5:0] sum
);
    assign sum = a + b;
endmodule