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

    mux2 M0 (.d0(carry_flag),    .d1(carry_in),    .sel(write_enable), .y(d_carry));
    mux2 M1 (.d0(overflow_flag), .d1(overflow_in), .sel(write_enable), .y(d_overflow));
    mux2 M2 (.d0(negative_flag), .d1(negative_in), .sel(write_enable), .y(d_negative));
    mux2 M3 (.d0(zero_flag),     .d1(zero_in),     .sel(write_enable), .y(d_zero));
    dff_async FF0 (.clk(clk), .rst_n(rst_n), .d(d_carry),    .q(carry_flag));
    dff_async FF1 (.clk(clk), .rst_n(rst_n), .d(d_overflow), .q(overflow_flag));
    dff_async FF2 (.clk(clk), .rst_n(rst_n), .d(d_negative), .q(negative_flag));
    dff_async FF3 (.clk(clk), .rst_n(rst_n), .d(d_zero),     .q(zero_flag));

endmodule