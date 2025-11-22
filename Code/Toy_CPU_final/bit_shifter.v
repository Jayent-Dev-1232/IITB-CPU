module bit_shifter (
    input wire select,
    input wire [7:0] I,
    output wire [7:0] O,
    output wire shift_out
);
    two_in_mux m0 (.a(I[0]), .b(I[7]), .sel(select), .y(shift_out));
    two_in_mux m1 (.a(I[1]), .b(1'b0), .sel(select), .y(O[0]));
    two_in_mux m2 (.a(I[2]), .b(I[0]), .sel(select), .y(O[1]));
    two_in_mux m3 (.a(I[3]), .b(I[1]), .sel(select), .y(O[2]));
    two_in_mux m4 (.a(I[4]), .b(I[2]), .sel(select), .y(O[3]));
    two_in_mux m5 (.a(I[5]), .b(I[3]), .sel(select), .y(O[4]));
    two_in_mux m6 (.a(I[6]), .b(I[4]), .sel(select), .y(O[5]));
    two_in_mux m7 (.a(I[7]), .b(I[5]), .sel(select), .y(O[6]));
    two_in_mux m8 (.a(1'b0), .b(I[6]), .sel(select), .y(O[7]));
endmodule