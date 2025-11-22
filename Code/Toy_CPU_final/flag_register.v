module flag_register (
    input  wire clk,
    input  wire rst_n,
    input  wire write_enable,

    input  wire carry_in,
    input  wire overflow_in,
    input  wire negative_in,
    input  wire zero_in,

    output wire carry_flag,
    output wire overflow_flag,
    output wire negative_flag,
    output wire zero_flag
);

    wire d_carry;
    wire d_overflow;
    wire d_negative;
    wire d_zero;

    two_in_mux M0 (.a(carry_flag),    .b(carry_in),    .sel(write_enable), .y(d_carry));
    two_in_mux M1 (.a(overflow_flag), .b(overflow_in), .sel(write_enable), .y(d_overflow));
    two_in_mux M2 (.a(negative_flag), .b(negative_in), .sel(write_enable), .y(d_negative));
    two_in_mux M3 (.a(zero_flag),     .b(zero_in),     .sel(write_enable), .y(d_zero));
    dff_async FF0 (.clk(clk), .rst_n(rst_n), .d(d_carry),    .q(carry_flag));
    dff_async FF1 (.clk(clk), .rst_n(rst_n), .d(d_overflow), .q(overflow_flag));
    dff_async FF2 (.clk(clk), .rst_n(rst_n), .d(d_negative), .q(negative_flag));
    dff_async FF3 (.clk(clk), .rst_n(rst_n), .d(d_zero),     .q(zero_flag));

endmodule