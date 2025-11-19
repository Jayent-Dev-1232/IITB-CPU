module flag_calculator (
    input wire [7:0] I,
    output wire zero,
    output wire negative
);
    zero = ~(I[0] | I[1] | I[2] | I[3] | I[4] | I[5] | I[6] | I[7]);
    negative = I[7];
endmodule