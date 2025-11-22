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

    // Data memory_array input: either switches (when c[15]==1) or register B
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


module final_CPU_tb;

    reg clk;
    reg reset;
    reg [15:0] switches;

    // Instantiate DUT (use the fixed CPU module if you saved it under that name)
    final_CPU DUT (
        .switches(switches),
        .clk(clk),
        .reset(reset)
    );

    // Clock: 10 ns period -> toggle every 5 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initialize and preload memories
    initial begin
        // Initialize inputs
        switches = 16'h0000;
        reset = 1;
        #20;
        reset = 0;

        // --- Preload DATA MEMORY (DMEM) ---
        // NOTE: Replace "memory_array" below with the actual internal data memory_array array name if different.
        // Example: if your data_memory.v declares "reg [7:0] memory_array [0:63];", this is correct.
        // If it declares "reg [7:0] mem [0:63];" replace "memory_array" with "mem".

        DUT.DMEM.memory_array[0] = 8'd7;   // DMEM[0] = 7
        DUT.DMEM.memory_array[1] = 8'd3;   // DMEM[1] = 3
        DUT.DMEM.memory_array[2] = 8'd2;   // DMEM[2] = 2
        DUT.DMEM.memory_array[3] = 8'd1;   // DMEM[3] = 1
        DUT.DMEM.memory_array[4] = 8'd6;   // DMEM[4] = 6
        DUT.DMEM.memory_array[5] = 8'd4;   // DMEM[5] = 4
        DUT.DMEM.memory_array[6] = 8'd5;   // DMEM[6] = 5
        DUT.DMEM.memory_array[7] = 8'd8;   // DMEM[7] = 8
        DUT.DMEM.memory_array[8] = 8'd7;   // DMEM[8] = 7 (your earlier code had an extra 7 at addr 8)

        // --- Preload CODE MEMORY (CMEM) instructions ---
        // Addresses given were binary 100000..110011 -> decimal 32..51
        // Replace "memory_array" with the actual internal array name in code_memory.v if different.

        DUT.CMEM.memory_array[32] = 16'b0011000000000000;
        DUT.CMEM.memory_array[33] = 16'b1000110000001000;
        DUT.CMEM.memory_array[34] = 16'b0011010000000000;
        DUT.CMEM.memory_array[35] = 16'b1101001100000000;
        DUT.CMEM.memory_array[36] = 16'b1111001100001110;
        DUT.CMEM.memory_array[37] = 16'b1000110000001000;
        DUT.CMEM.memory_array[38] = 16'b0110110000000000;
        DUT.CMEM.memory_array[39] = 16'b1101011100000000;
        DUT.CMEM.memory_array[40] = 16'b1111001100001000;
        DUT.CMEM.memory_array[41] = 16'b1001100100000000;
        DUT.CMEM.memory_array[42] = 16'b1001110100000001;
        DUT.CMEM.memory_array[43] = 16'b1101111000000000;
        DUT.CMEM.memory_array[44] = 16'b1111001100000010;
        DUT.CMEM.memory_array[45] = 16'b1011110100000000;
        DUT.CMEM.memory_array[46] = 16'b1011100100000001;
        DUT.CMEM.memory_array[47] = 16'b0101010000000001;
        DUT.CMEM.memory_array[48] = 16'b1110000011110100;
        DUT.CMEM.memory_array[49] = 16'b0101000000000001;
        DUT.CMEM.memory_array[50] = 16'b1110000011101110;
        DUT.CMEM.memory_array[51] = 16'b0000000000000000;

        // Let the DUT settle a little before execution (optional)
        #10;
    end

    // Dump waveform and run simulation
    initial begin
        $dumpfile("final_CPU_tb.vcd");
        $dumpvars(0, final_CPU_tb);

        // Give time for program to run - adjust cycles depending on program complexity
        // Here we wait for 2000 clock cycles (2000 * 10ns = 20 us)
        repeat (20000) @(posedge clk);

        // Print Data Memory contents (explicit indices)
        $display("\n==== DMEM contents after execution ====");
        $display("Addr | Data (decimal) | Data (binary)");
        $display("-------------------------------------");
        $display("  0  | %0d | %b", DUT.DMEM.memory_array[0], DUT.DMEM.memory_array[0]);
        $display("  1  | %0d | %b", DUT.DMEM.memory_array[1], DUT.DMEM.memory_array[1]);
        $display("  2  | %0d | %b", DUT.DMEM.memory_array[2], DUT.DMEM.memory_array[2]);
        $display("  3  | %0d | %b", DUT.DMEM.memory_array[3], DUT.DMEM.memory_array[3]);
        $display("  4  | %0d | %b", DUT.DMEM.memory_array[4], DUT.DMEM.memory_array[4]);
        $display("  5  | %0d | %b", DUT.DMEM.memory_array[5], DUT.DMEM.memory_array[5]);
        $display("  6  | %0d | %b", DUT.DMEM.memory_array[6], DUT.DMEM.memory_array[6]);
        $display("  7  | %0d | %b", DUT.DMEM.memory_array[7], DUT.DMEM.memory_array[7]);
        $display("  8  | %0d | %b", DUT.DMEM.memory_array[8], DUT.DMEM.memory_array[8]);

        // Save DMEM to file (optional) - replace 'memory_array' with your internal name if needed
        $writememh("final_dmem_dump.hex", DUT.DMEM.memory_array);

        $display("\nSimulation done. DMEM dumped to final_dmem_dump.hex");
        $finish;
    end

endmodule
