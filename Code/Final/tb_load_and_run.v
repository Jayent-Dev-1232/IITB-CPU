`timescale 1ns/1ps

module tb_load_and_run;

    // -----------------------------
    // Signals
    // -----------------------------
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg [15:0] switches = 16'd0;

    wire [26:0] op_o;
    wire [15:0] instr_o;
    wire [5:0]  pc_o;
    wire        pc_mux_o;
    wire        im_write_o;

    wire [127:0] data;   // packed memory bus (128 bits)
    wire [31:0]  reges;  // packed registers

    wire [4:0]   opi_o;
    wire [3:0]   flags_out;
    wire [7:0]   alu_result;

    // -----------------------------
    // Instantiate CPU
    // -----------------------------
    cpu uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .op_o(op_o),
        .instr_o(instr_o),
        .pc_o(pc_o),
        .pc_mux_o(pc_mux_o),
        .im_write_o(im_write_o),
        .data(data),
        .reges(reges),
        .opi_o(opi_o),
        .flags_out(flags_out),
        .alu_res_o(alu_result)
    );

    // -----------------------------
    // Split DATA into 16 bytes
    // -----------------------------
    wire [7:0] d0  = data[7:0];
    wire [7:0] d1  = data[15:8];
    wire [7:0] d2  = data[23:16];
    wire [7:0] d3  = data[31:24];
    wire [7:0] d4  = data[39:32];
    wire [7:0] d5  = data[47:40];
    wire [7:0] d6  = data[55:48];
    wire [7:0] d7  = data[63:56];
    wire [7:0] d8  = data[71:64];
    wire [7:0] d9  = data[79:72];
    wire [7:0] d10 = data[87:80];
    wire [7:0] d11 = data[95:88];
    wire [7:0] d12 = data[103:96];
    wire [7:0] d13 = data[111:104];
    wire [7:0] d14 = data[119:112];
    wire [7:0] d15 = data[127:120];

    // -----------------------------
    // Clock (20ns period)
    // -----------------------------
    always #10 clk = ~clk;

    // -----------------------------
    // Waveform Dump
    // -----------------------------
    initial begin
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, tb_load_and_run);

        // REMOVE big 128-bit bus from view
        $dumpvars(0, d0, d1, d2, d3, d4, d5, d6, d7,
                     d8, d9, d10, d11, d12, d13, d14, d15);
    end

    // -----------------------------
    // Reset
    // -----------------------------
    initial begin
        rst = 1'b1;
        #50;
        rst = 1'b0;
    end

    // -----------------------------
    // Final Output After Sorting
    // -----------------------------
    initial begin
        // Wait long enough for bubble sort to finish
        #60000;

        $display("\n--------------------------------------------");
        $display("Array given for bubble sorting :- 7, 3, 2, 1, 6, 4, 5, 8");
        $display("Final sorted array :- ");
        $write("%0d %0d %0d %0d %0d %0d %0d %0d\n",
            d0, d1, d2, d3, d4, d5, d6, d7
        );
        $display("--------------------------------------------\n");

        $finish;
    end

endmodule