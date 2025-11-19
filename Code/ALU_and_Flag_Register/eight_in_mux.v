module eight_in_mux (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire sel,
    output wire [7:0] y
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : mux_loop
            two_in_mux mux_inst (
                .a(a[i]),
                .b(b[i]),
                .sel(sel),
                .y(y[i])
            );
        end
    endgenerate
    
endmodule