module two_in_mux (
    input wire a,
    input wire b,
    input wire sel,
    output wire y
);
    assign y = (sel == 1'b0) ? b : a;
endmodule