// cpu.v : top-level CPU (two-stage decode) — Verilog translation of cpu.vhdl

`timescale 1ns/1ps

module cpu (
    input  wire         clk,
    input  wire         rst,
    input  wire [15:0]  switches,   // external switches / input bus (low 8 bits used)

    output wire [26:0]  op_o,
    output wire [15:0]  instr_o,
    output wire [5:0]   pc_o,
    output wire         pc_mux_o,
    output wire         im_write_o,
    output wire [127:0] data,       // byte_array16 flattened -> 16 * 8 = 128 bits
    output wire [31:0]  reges,      // byte_array4 flattened -> 4 * 8 = 32 bits
    output wire [4:0]   opi_o,
    output wire [3:0]   flags_out,
    output wire [7:0]   alu_res_o
);

    // Program counter and instruction fetch
    wire  [5:0]  pc;
    wire [15:0] instr;
    wire [127:0] data_led;

    // Decoded fields (two-stage)
    wire [26:0] opcode;

    // Register file interface (4 registers A,B,C,D of 8-bit)
    wire [1:0]  reg_port0_sel;
    wire [1:0]  reg_port1_sel;
    wire [1:0]  reg_write_sel;
    wire        reg_write_en;
    wire        reg_writeback_mux;
    wire [7:0]  reg_out_p0;
    wire [7:0]  reg_out_p1;
    wire [7:0]  reg_wdata;

    // ALU
    wire        alu_src_mux;
    wire [1:0]  alu_op;
    wire [7:0]  alu_b;
    wire [7:0]  alu_result8;
    wire [7:0]  alu_result;
    wire        flag_write_en;
    wire [3:0]  flags;     // outputs from ALU (carry,overflow,negative,zero)
    wire [3:0]  flags_r;   // registered flags (from flag_reg)

    // ALU result mux
    wire        alu_result_mux;

    // Data memory (16 x 8-bit)
    wire        dmem_input_mux;
    wire        dmem_write_en;
    wire [3:0]  dmem_addr4;
    wire [7:0]  dmem_wdata8;
    wire [7:0]  dmem_rdata8;

    // Code memory write port (for loader/testbench)
    wire        im_write;
    wire [5:0]  im_waddr;
    wire [15:0] im_wdata;

    // PC control signals
    wire        pc_mux;
    wire        pc_we;

    // internal opi from control
    wire [4:0] opi_O;

    // ------------------------------------------------------------
    // pc_update instance (same ports as VHDL)
    // expecting module: pc_update(clk, rst, pc_we, pc_mux, load_val, pc_out)
    // load_val = instr[5:0]
    // ------------------------------------------------------------
    pc_update pc_inst (
        .clk      (clk),
        .rst      (rst),
        .pc_we    (pc_we),
        .pc_mux   (pc_mux),
        .load_val (instr[5:0]),
        .pc_out   (pc)
    );

    // ------------------------------------------------------------
    // code_memory instance (64 x 16)
    // write_enable => im_write
    // write_addr   => alu_result[5:0]
    // write_data   => switches (16-bit)
    // ------------------------------------------------------------
    code_memory imem (
        .clk          (clk),
        .addr         (pc),
        .data_out     (instr),
        .write_enable (im_write),
        .write_addr   (alu_result[5:0]),
        .write_data   (switches)
    );

    // ------------------------------------------------------------
    // Two-stage decode: opcode extractor (instr[15:8] -> opcode)
    // ------------------------------------------------------------
    opcode_decoder decoder (
        .instr  (instr[15:8]),
        .opcode (opcode)
    );

    // ------------------------------------------------------------
    // Flag register: accepts flags from ALU and writes them when c14 asserted
    // VHDL mapping:
    //   carry => flags(3),
    //   overflow => flags(2),
    //   negative => flags(1),
    //   zero => flags(0),
    //   clk => clk,
    //   c14 => flag_write_en,
    //   y => flags_r
    // ------------------------------------------------------------
    flag_reg flag (
        .carry    (flags[3]),
        .overflow (flags[2]),
        .negative (flags[1]),
        .zero     (flags[0]),
        .clk      (clk),
        .c14      (flag_write_en),
        .y        (flags_r)
    );

    // ------------------------------------------------------------
    // Control unit (maps opcode + flags_r -> many control signals)
    // opi_o => opi_O (internal), we expose opi_O as opi_o port
    // ------------------------------------------------------------
    control control_unit (
        .opcode            (opcode),
        .flags             (flags_r),

        .imem_we           (/* connected inside control -> im_write (wire) */ im_write),
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

    // ------------------------------------------------------------
    // Register file: 4 registers, 8-bit each
    // Expecting module register_file with ports:
    //  clk, rst, port0_sel, port1_sel, write_sel, write_en, write_data, out0, out1, reges
    // ------------------------------------------------------------
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

    // ------------------------------------------------------------
    // ALU B input selection (c11): 0 => reg_out_p1, 1 => instr[7:0]
    // ------------------------------------------------------------
    assign alu_b = (alu_src_mux == 1'b0) ? reg_out_p1 : instr[7:0];

    // ------------------------------------------------------------
    // ALU instance
    // ports: a,b,op,result,carry,overflow,negative,zero
    // VHDL wired: a <= reg_out_p0; b <= alu_b; op <= alu_op; result => alu_result8; flags <= outputs
    // ------------------------------------------------------------
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

    // ------------------------------------------------------------
    // Data memory (16 x 8)
    // ports: clk, addr, data_in, write_enable, data_out, data_led
    // addr comes from ALU low nibble (alu_result[3:0])
    // ------------------------------------------------------------
    data_memory dmem (
        .clk          (clk),
        .addr         (alu_result[3:0]),
        .data_in      (dmem_wdata8),
        .write_enable (dmem_write_en),
        .data_out     (dmem_rdata8),
        .data_led     (data_led)
    );

    // ------------------------------------------------------------
    // DMEM input MUX (c16): selects switches low byte or reg_out_p1
    // ------------------------------------------------------------
    assign dmem_wdata8 = (dmem_input_mux == 1'b1) ? switches[7:0] : reg_out_p1;

    // ------------------------------------------------------------
    // Register writeback selection and priority:
    // reg_writeback_mux: '0' = ALU result, '1' = dmem_rdata8 (or imm/switches depending on control)
    // reg_wdata <= alu_result when reg_writeback_mux = '0' else dmem_rdata8;
    // ------------------------------------------------------------
    // alu_result mux: alu_result <= alu_result8 when alu_result_mux = '0' else instr[7:0];
    assign alu_result = (alu_result_mux == 1'b0) ? alu_result8 : instr[7:0];

    assign reg_wdata = (reg_writeback_mux == 1'b0) ? alu_result : dmem_rdata8;

    // ------------------------------------------------------------
    // Outputs mapping (same as VHDL final assignments)
    // ------------------------------------------------------------
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

    // -----------------------------
    // Signals
    // -----------------------------
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg [15:0] switches = 16'd0;

    wire [26:0] op_o;
    wire [15:0] instr_o;
    wire [5:0]  pc_o;
    wire pc_mux_o;
    wire im_write_o;

    // <-- CHANGED: packed buses instead of unpacked arrays
    wire [127:0] data;
    wire [31:0]  reges;

    wire [4:0] opi_o;
    wire [3:0] flags_out;
    wire [7:0] alu_result;

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
        .data(data),       // now packed [127:0]
        .reges(reges),     // now packed [31:0]
        .opi_o(opi_o),
        .flags_out(flags_out),
        .alu_res_o(alu_result)
    );

    // -----------------------------
    // Clock generator (period = 20ns)
    // -----------------------------
    always #10 clk = ~clk;

    // -----------------------------
    // Waveform Dump Setup
    // -----------------------------
    initial begin
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, tb_load_and_run);
    end

    // -----------------------------
    // Reset pulse
    // -----------------------------
    initial begin
        rst = 1'b1;
        #50;
        rst = 1'b0;
    end

    // -----------------------------
    // Debug printing (optional)
    // -----------------------------
    always @(posedge clk) begin
        // print packed-slice bytes
        $display("TIME=%0t | PC=%0d | INSTR=%h | ALU=%h | FLAGS=%b | op=%h | R0=%02h R1=%02h R2=%02h R3=%02h DMEM0=%02h DMEM1=%02h",
            $time, pc_o, instr_o, alu_result, flags_out, op_o,
            reges[7:0], reges[15:8], reges[23:16], reges[31:24],
            data[7:0], data[15:8]
        );
    end

    // -----------------------------
    // Test run duration
    // -----------------------------
    initial begin
        #100000;
        $display("Simulation complete.");
        $finish;
    end

endmodule