`timescale 1ns / 1ps

module final_CPU (
    input wire [15:0] switches,
    input wire clk,
    input wire reset
);
    wire [7:0] DMEM_data_in;
    wire [7:0] register_B_data_out;
    wire [7:0] register_A_data_out;
    wire [17:0] c;
    wire [7:0] ALU_result_mux;
    wire [7:0] DMEM_data_out;
    wire [7:0] REG_writeback_mux;
    wire [15:0] CMEM_out;
    wire [7:0] ALU_result;
    wire carry_in;
    wire overflow_in;
    wire zero_in;
    wire negative_in;
    wire [7:0] ALU_source_B_mux;
    wire carry_flag;
    wire overflow_flag;
    wire zero_flag;
    wire negative_flag;
    wire [5:0] program_counter_out;
    wire [26:0] decoder_output;
    wire [1:0] write_select;
    wire [1:0] port_A_select;
    wire [1:0] port_B_select;
    wire [1:0] alu_select_input;

    assign DMEM_data_in = c[15] ? switches[7:0] : register_B_data_out;

    data_memory DMEM (
        .data_in(DMEM_data_in),
        .write_select(ALU_result_mux[3:0]),
        .read_select(ALU_result_mux[3:0]),
        .select(c[16]),
        .data_out(DMEM_data_out)
    );

    assign REG_writeback_mux = c[17] ? DMEM_data_out : ALU_result_mux;

    assign write_select[1] = c[7];
    assign write_select[0] = c[8];
    assign port_A_select[1] = c[3];
    assign port_A_select[0] = c[4];
    assign port_B_select[1] = c[5];
    assign port_B_select[0] = c[6];

    register_file REG (
        .clk(clk),
        .reset(reset),
        .write_en(c[9]),
        .write_sel(write_select),
        .port_a_sel(port_A_select),
        .port_b_sel(port_B_select),
        .input_data(REG_writeback_mux),
        .port_a_data(register_A_data_out),
        .port_b_data(register_B_data_out)
    );

    assign ALU_source_B_mux = c[10] ? CMEM_out[7:0] : register_B_data_out;

    assign alu_select_input[1] = c[11];
    assign alu_select_input[0] = c[12];
    ALU ALU_unit (
        .ALU_select(alu_select_input),
        .A(register_A_data_out),
        .B(ALU_source_B_mux),
        .ALU_result(ALU_result),
        .carry(carry_in),
        .overflow(overflow_in),
        .zero(zero_in),
        .negative(negative_in)
    );

    assign ALU_result_mux = c[14] ? CMEM_out[7:0] : ALU_result;

    flag_registers flag_unit (
        .clk(clk),
        .rst_n(reset),
        .write_enable(c[13]),
        .carry_in(carry_in),
        .overflow_in(overflow_in),
        .negative_in(negative_in),
        .zero_in(zero_in),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .negative_flag(negative_flag),
        .zero_flag(zero_flag)
    );

    code_memory CMEM (
        .data_in(switches),
        .write_select(ALU_result_mux[5:0]),
        .read_select(program_counter_out),
        .select(c[0]),
        .data_out(CMEM_out)
    );

    opcode_decoder opcodes (
        .A(CMEM_out[15:8]),
        .Y(decoder_output)
    );

    control_unit controls (
        .opcode_in(decoder_output),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .negative_flag(negative_flag),
        .zero_flag(zero_flag),
        .control(c)
    );

    program_counter pc_logic (
        .A0(CMEM_out[5:0]),
        .A1(program_counter_out),
        .clk(clk),
        .c2(c[1]),
        .c3(c[2]),
        .Y(program_counter_out)
    );
endmodule

module testbench;
    reg reset,clk;
    wire [7:0] bluff;
    final_CPU dut(16'b0000000000000000, clk, reset);

    initial begin
        $dumpfile("CPU_final.vcd");
        $dumpvars(0, testbench);

        reset = 1'b0;
        #5;
        reset = 1'b1;
        #10;
        reset = 1'b0;
        #99;
        $finish;
    end

    initial clk = 1'b1;
    always #5 clk = ~clk;

endmodule