`timescale 1ns/1ps

module cpu (
    input  wire         clk,
    input  wire         rst,
    input  wire [15:0]  switches,

    output wire [26:0]  op_o,
    output wire [15:0]  instr_o,
    output wire [5:0]   pc_o,
    output wire         pc_mux_o,
    output wire         im_write_o,
    output wire [127:0] data,
    output wire [31:0]  reges,
    output wire [4:0]   opi_o,
    output wire [3:0]   flags_out,
    output wire [7:0]   alu_res_o
);

    wire  [5:0]  pc;
    wire [15:0] instr;
    wire [127:0] data_led;

    wire [26:0] opcode;

    wire [1:0]  reg_port0_sel;
    wire [1:0]  reg_port1_sel;
    wire [1:0]  reg_write_sel;
    wire        reg_write_en;
    wire        reg_writeback_mux;
    wire [7:0]  reg_out_p0;
    wire [7:0]  reg_out_p1;
    wire [7:0]  reg_wdata;

    wire        alu_src_mux;
    wire [1:0]  alu_op;
    wire [7:0]  alu_b;
    wire [7:0]  alu_result8;
    wire [7:0]  alu_result;
    wire        flag_write_en;
    wire [3:0]  flags;
    wire [3:0]  flags_r;

    wire        alu_result_mux;

    wire        dmem_input_mux;
    wire        dmem_write_en;
    wire [3:0]  dmem_addr4;
    wire [7:0]  dmem_wdata8;
    wire [7:0]  dmem_rdata8;

    wire        im_write;
    wire [5:0]  im_waddr;
    wire [15:0] im_wdata;

    wire        pc_mux;
    wire        pc_we;

    wire [4:0] opi_O;

    pc_update pc_inst (
        .clk      (clk),
        .rst      (rst),
        .pc_we    (pc_we),
        .pc_mux   (pc_mux),
        .load_val (instr[5:0]),
        .pc_out   (pc)
    );

    code_memory imem (
        .clk          (clk),
        .addr         (pc),
        .data_out     (instr),
        .write_enable (im_write),
        .write_addr   (alu_result[5:0]),
        .write_data   (switches)
    );

    opcode_decoder decoder (
        .instr  (instr[15:8]),
        .opcode (opcode)
    );

    flag_reg flag (
        .carry    (flags[3]),
        .overflow (flags[2]),
        .negative (flags[1]),
        .zero     (flags[0]),
        .clk      (clk),
        .c14      (flag_write_en),
        .y        (flags_r)
    );

    control control_unit (
        .opcode            (opcode),
        .flags             (flags_r),

        .imem_we           (im_write),
        .pc_mux            (pc_mux),
        .pc_we             (pc_we),
        .reg_port0_sel     (reg_port0_sel),
        .reg_port1_sel     (reg_port1_sel),
        .reg_write_sel     (reg_write_sel),
        .reg_write_en      (reg_write_en),
        .alu_src_mux       (alu_src_mux),
        .alu_op            (alu_op),
        .flag_write_en     (flag_write_en),
        .alu_result_mux    (alu_result_mux),
        .dmem_input_mux    (dmem_input_mux),
        .dmem_write_en     (dmem_write_en),
        .reg_writeback_mux (reg_writeback_mux),
        .opi_o             (opi_O)
    );

    register_file regs_inst (
        .clk        (clk),
        .rst        (rst),
        .port0_sel  (reg_port0_sel),
        .port1_sel  (reg_port1_sel),
        .write_sel  (reg_write_sel),
        .write_en   (reg_write_en),
        .write_data (reg_wdata),
        .out0       (reg_out_p0),
        .out1       (reg_out_p1),
        .reges_3    (reges[31:24]),
        .reges_2    (reges[23:16]),
        .reges_1    (reges[15:8]),
        .reges_0    (reges[7:0]) 
    );

    assign alu_b = (alu_src_mux == 1'b0) ? reg_out_p1 : instr[7:0];

    alu alu_inst (
        .a        (reg_out_p0),
        .b        (alu_b),
        .op       (alu_op),
        .result   (alu_result8),
        .carry    (flags[3]),
        .overflow (flags[2]),
        .negative (flags[1]),
        .zero     (flags[0])
    );

    data_memory dmem (
        .clk          (clk),
        .addr         (alu_result[3:0]),
        .data_in      (dmem_wdata8),
        .write_enable (dmem_write_en),
        .data_out     (dmem_rdata8),
        .data_led     (data_led)
    );

    assign dmem_wdata8 = (dmem_input_mux == 1'b1) ? switches[7:0] : reg_out_p1;

    assign alu_result = (alu_result_mux == 1'b0) ? alu_result8 : instr[7:0];

    assign reg_wdata = (reg_writeback_mux == 1'b0) ? alu_result : dmem_rdata8;

    assign instr_o     = instr;
    assign pc_o        = pc;
    assign pc_mux_o    = pc_mux;
    assign im_write_o  = im_write;
    assign op_o        = opcode;
    assign data        = data_led;
    assign flags_out   = flags_r;
    assign alu_res_o   = alu_result;
    assign opi_o       = opi_O;

endmodule


module tb_load_and_run;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg [15:0] switches = 16'd0;

    wire [26:0] op_o;
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
