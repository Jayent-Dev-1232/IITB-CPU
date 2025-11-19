module ALU (
    input wire [1:0]ALU_select,
    input wire [7:0]A,
    input wire [7:0]B,
    output wire [7:0]ALU_result,
    output wire carry,
    output wire overflow,
    output wire zero,
    output wire negative
);
    wire [7:0]adder_result;
    wire adder_carry;
    wire adder_overflow;
    wire [7:0]shifter_result;
    wire shifter_carry;

    bit_shifter shifter (
        .select(ALU_select[0]),
        .I(A),
        .O(shifter_result),
        .shift_out(shifter_carry)
    );
    bit_adder adder (
        .X(A),
        .Y(B),
        .add_sub(ALU_select[0]),
        .S(adder_result),
        .overflow(adder_overflow),
        .carry(adder_carry)
    );
    eight_in_mux result_mux (
        .a(shifter_result),
        .b(adder_result),
        .sel(ALU_select[1]),
        .y(ALU_result)
    );
    two_in_mux carry_mux (
        .a(adder_carry),
        .b(shifter_carry),
        .sel(ALU_select[1]),
        .y(carry)
    );
    two_in_mux overflow_mux (
        .a(adder_overflow),
        .b(1'b0),
        .sel(ALU_select[1]),
        .y(overflow)
    );
    flag_calculator flag_calc (
        .I(ALU_result),
        .zero(zero),
        .negative(negative)
    );
endmodule