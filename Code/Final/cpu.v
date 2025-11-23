`timescale 1ns/1ps

module cpu (
    input  wire         clk, // clock
    input  wire         rst, // active high synchronous reset
    input  wire [15:0]  switches, // externally input from user

    output wire [26:0]  op_o, // output of opcode decoder
    output wire [15:0]  instr_o, // output of code memory
    output wire [5:0]   pc_o, // debug output of program memory
    output wire         pc_mux_o, // debug select of PC MUX
    output wire         im_write_o, // debug code memory write enable
    output wire [127:0] data, // 16 bytes of data memory
    output wire [31:0]  reges, // 4 bytes of register data
    output wire [4:0]   opi_o, // debug address of one hot encoded opcode
    output wire [3:0]   flags_out, // debug break flags
    output wire [7:0]   alu_res_o // debug ALU output
);

    wire  [5:0]  pc;
    wire [15:0] instr;
    wire [127:0] data_output;

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
    wire [1:0]  ALU_select;
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

    program_counter pc_inst (
        .clk      (clk),
        .rst      (rst),
        .pc_write_en    (pc_we),
        .pc_mux   (pc_mux),
        .offset_val (instr[5:0]),
        .pc_out   (pc)
    );

    code_mem imem (
        .clk          (clk),
        .read_address         (pc),
        .data_out     (instr),
        .write_en (im_write),
        .write_address   (alu_result[5:0]),
        .write_data   (switches)
    );

    opcode_decoder decoder (
        .cmem_in  (instr[15:8]),
        .opcode (opcode)
    );

    flag_register flag (
        .carry    (flags[3]),
        .overflow (flags[2]),
        .negative (flags[1]),
        .zero     (flags[0]),
        .clk      (clk),
        .flag_write_en      (flag_write_en),
        .y        (flags_r)
    );

    control_unit control_unit (
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
        .alu_select            (ALU_select),
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
        .ALU_select       (ALU_select),
        .ALU_result   (alu_result8),
        .carry    (flags[3]),
        .overflow (flags[2]),
        .negative (flags[1]),
        .zero     (flags[0])
    );

    data_mem dmem (
        .clk          (clk),
        .address         (alu_result[3:0]),
        .data_in      (dmem_wdata8),
        .write_en (dmem_write_en),
        .data_out     (dmem_rdata8),
        .data_output     (data_output)
    );

    assign dmem_wdata8 = (dmem_input_mux == 1'b1) ? switches[7:0] : reg_out_p1;

    assign alu_result = (alu_result_mux == 1'b0) ? alu_result8 : instr[7:0];

    assign reg_wdata = (reg_writeback_mux == 1'b0) ? alu_result : dmem_rdata8;

    assign instr_o     = instr;
    assign pc_o        = pc;
    assign pc_mux_o    = pc_mux;
    assign im_write_o  = im_write;
    assign opcode_output        = opcode;
    assign data        = data_output;
    assign flags_out   = flags_r;
    assign alu_res_o   = alu_result;
    assign opi_o       = opi_O;

endmodule




