`timescale 1ns/1ps

module tb_load_and_run;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg [15:0] switches = 16'd0;

    wire [26:0] opcode_output;
    wire [15:0] instr_o;
    wire [5:0]  pc_o;
    wire pc_mux_o;
    wire im_write_o;

    wire [127:0] data;
    wire [31:0]  reges;

    wire [4:0] opi_o;
    wire [3:0] flags_out;
    wire [7:0] alu_result;

    cpu uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .opcode_output
(opcode_output
),
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

    always #10 clk = ~clk;

    initial begin
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, tb_load_and_run);
    end

    initial begin
        rst = 1'b1;
        #50;
        rst = 1'b0;
    end

    initial begin
        #100000;

        $display("\n--------------------------------------------");
        $display("Array given for bubble sorting :- 7, 3, 2, 1, 6, 4, 5, 8");

        $display("Final sorted Array = [%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d]",
            data[7:0],
            data[15:8],
            data[23:16],
            data[31:24],
            data[39:32],
            data[47:40],
            data[55:48],
            data[63:56]
        );

        $display("--------------------------------------------\n");


        $finish;
    end

endmodule