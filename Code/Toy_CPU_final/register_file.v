module register_file (
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire [1:0] write_sel, port_a_sel, port_b_sel,
    input wire [7:0] input_data,
    output wire [7:0] port_a_data, port_b_data
);
    wire [7:0] reg0_out, reg1_out, reg2_out, reg3_out;

    registers R0 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b00)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg0_out)
    );

    registers R1 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b01)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg1_out)
    );

    registers R2 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b10)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg2_out)
    );

    registers R3 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b11)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg3_out)
    );

    four_in_mux muxA (
        .a(reg0_out), .b(reg1_out), .c(reg2_out), .d(reg3_out),
        .sel(port_a_sel), .y(port_a_data)
    );

    four_in_mux muxB (
        .a(reg0_out), .b(reg1_out), .c(reg2_out), .d(reg3_out),
        .sel(port_b_sel), .y(port_b_data)
    );

endmodule