module register_file (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  port0_sel,
    input  wire [1:0]  port1_sel,
    input  wire [1:0]  write_sel,
    input  wire        write_en,
    input  wire [7:0]  write_data,
    output wire [7:0]  out0,
    output wire [7:0]  out1,
    output wire [7:0]  reges_0,
    output wire [7:0]  reges_1,
    output wire [7:0]  reges_2,
    output wire [7:0]  reges_3
);

    // 4 registers as an array (LEGAL Verilog-2001)
    reg [7:0] regs [0:3];

    // Export individual registers
    assign reges_0 = regs[0];
    assign reges_1 = regs[1];
    assign reges_2 = regs[2];
    assign reges_3 = regs[3];

    // Combinational read ports
    assign out0 = regs[port0_sel];
    assign out1 = regs[port1_sel];

    // Write on falling edge, reset async
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            regs[0] <= 8'b0;
            regs[1] <= 8'b0;
            regs[2] <= 8'b0;
            regs[3] <= 8'b0;
        end else if (write_en) begin
            regs[write_sel] <= write_data;
        end
    end

endmodule