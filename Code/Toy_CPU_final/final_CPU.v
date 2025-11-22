`timescale 1ns / 1ps

module final_CPU (
    input wire clk,
    input wire reset,
    input wire [15:0] program_input,
    input wire [15:0] switches,
    output wire [7:0] debug_port_a,
    output wire [7:0] debug_alu_out
);

    wire [5:0] pc_current;
    wire [5:0] pc_next;
    wire [5:0] pc_plus_one;
    wire [5:0] pc_branch_target;
    
    wire [15:0] instruction;
    wire [7:0] opcode_bus_high = instruction[15:8];
    wire [7:0] operand_bus_low = instruction[7:0];
    
    wire [26:0] decoded_opcode;
    wire [17:0] c;

    wire [7:0] reg_port_a_out;
    wire [7:0] reg_port_b_out;
    wire [7:0] writeback_data;

    wire [7:0] alu_source_mux_out;
    wire [7:0] alu_result;
    wire [7:0] alu_result_mux_out;
    wire flag_carry, flag_overflow, flag_negative, flag_zero;
    wire carry_out, overflow_out, negative_out, zero_out;
    wire [3:0] flag_bus = {flag_zero, flag_negative, flag_overflow, flag_carry};
    
    wire [7:0] dmem_mux_out;
    wire [7:0] dmem_data_out;

    wire rst_n = ~reset;

    pc_update_logic PC_LOGIC (
        .A0(pc_current),
        .A1(operand_bus_low[5:0]),
        .Y0(pc_plus_one),
        .Y1(pc_branch_target)
    );

    assign pc_next = (c[1]) ? pc_branch_target : pc_plus_one;

    program_counter PC (
        .A(pc_next),
        .c3(c[2]),
        .Y(pc_current)
    );

    code_memory IMEM (
        .data_in(program_input),
        .write_select(program_input[5:0]),
        .read_select(pc_current),
        .select(c[0]),
        .data_out(instruction)
    );

    opcode_decoder DECODER (
        .A(opcode_bus_high),
        .Y(decoded_opcode)
    );

    control_unit CONTROL (
        .opcode_in(decoded_opcode),
        .break_flag(flag_bus),
        .control(c)
    );

    register_file REG_FILE (
        .clk(clk),
        .reset(reset),
        .write_en(c[9]),
        .write_sel({c[7], c[8]}),
        .port_a_sel({c[3], c[4]}),
        .port_b_sel({c[5], c[6]}),
        .input_data(writeback_data),
        .port_a_data(reg_port_a_out),
        .port_b_data(reg_port_b_out)
    );
    
    eight_in_mux ALU_SRC_MUX (
        .a(operand_bus_low),
        .b(reg_port_b_out),
        .sel(c[10]),
        .y(alu_source_mux_out)
    );

    ALU CPU_ALU (
        .ALU_select({c[11], c[12]}),
        .A(reg_port_a_out),
        .B(alu_source_mux_out),
        .ALU_result(alu_result),
        .carry(carry_out),
        .overflow(overflow_out),
        .zero(zero_out),
        .negative(negative_out)
    );

    flag_register FLAGS (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(c[13]),
        .carry_in(carry_out),
        .overflow_in(overflow_out),
        .negative_in(negative_out),
        .zero_in(zero_out),
        .carry_flag(flag_carry),
        .overflow_flag(flag_overflow),
        .negative_flag(flag_negative),
        .zero_flag(flag_zero)
    );

    eight_in_mux DMEM_IN_MUX (
        .a(switches[7:0]),
        .b(reg_port_b_out),
        .sel(c[15]),
        .y(dmem_mux_out)
    );

    data_memory DMEM (
        .data_in(dmem_mux_out),
        .write_select(operand_bus_low[3:0]),
        .read_select(operand_bus_low[3:0]),
        .select(c[16]),
        .data_out(dmem_data_out)
    );

    eight_in_mux ALU_RES_MUX (
        .a(dmem_data_out),
        .b(alu_result),
        .sel(c[14]),
        .y(alu_result_mux_out)
    );

    eight_in_mux WB_MUX (
        .a(operand_bus_low),
        .b(alu_result_mux_out),
        .sel(c[17]),
        .y(writeback_data)
    );

    assign debug_port_a = reg_port_a_out;
    assign debug_alu_out = alu_result;

endmodule



module tb_integrated_cpu;

    // ============================================================
    // 1. Signals and Constants
    // ============================================================
    reg clk;
    reg reset;
    reg [15:0] program_input;
    reg [15:0] switches;
    
    wire [7:0] debug_port_a;
    wire [7:0] debug_alu_out;

    // Clock Period (10ns = 100MHz)
    localparam CLK_PERIOD = 10;

    // ============================================================
    // 2. Instantiate the Integrated CPU
    // ============================================================
    final_CPU uut (
        .clk(clk),
        .reset(reset),
        .program_input(program_input),
        .switches(switches),
        .debug_port_a(debug_port_a),   // Connects to Register Port A output
        .debug_alu_out(debug_alu_out)  // Connects to ALU Result
    );
    // ============================================================
    // GTKWave Dump Setup
    // ============================================================
    initial begin
        // Specify the name of the dump file
        $dumpfile("cpu_wave.vcd");
        
        // Dump all variables (level 0) starting from the testbench instance
        $dumpvars(0, tb_integrated_cpu); 
    end

    // ============================================================
    // 3. Clock Generation
    // ============================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ============================================================
    // 4. Test Procedure
    // ============================================================
    initial begin
        // --- Initialize Inputs ---
        reset = 1;          // Active High Reset (based on your cpu design)
        program_input = 0;
        switches = 0;

        // --- Load Test Program into Instruction Memory ---
        // Note: This writes directly to the memory array inside the instance.
        // Based on opcode_decoder analysis:
        // Opcode '5' (High Nibble 0x5) -> Y[8] -> ADDI
        // Since opcode_decoder might default X0/X1 to 0, this targets Register 0.
        
        $display("Loading Instruction Memory...");
        
        // Instruction 0: ADDI 5 (Reg0 = Reg0 + 5)
        // Opcode: 0x5 (ADDI), Operand: 0x05
        uut.IMEM.memory_array[0] = 16'h5005; 

        // Instruction 1: ADDI 10 (Reg0 = Reg0 + 10)
        // Opcode: 0x5 (ADDI), Operand: 0x0A
        uut.IMEM.memory_array[1] = 16'h500A;

        // Instruction 2: SUBI 2 (Reg0 = Reg0 - 2)
        // Opcode '7' (0x7) -> Y[10] -> SUBI (Based on decoder map: Y[10] = B[7])
        // Opcode: 0x7 (SUBI), Operand: 0x02
        uut.IMEM.memory_array[2] = 16'h7002;

        // Instruction 3: NOOP (Do nothing / Halt loop)
        // Opcode: 0x0
        uut.IMEM.memory_array[3] = 16'h0000;

        // --- Start Simulation ---
        $display("Starting Simulation...");
        
        // Hold Reset
        #20;
        reset = 0; // Release Reset
        $display("Reset Released.");

        // --- Cycle-by-Cycle Check ---
        
        // 1. Execute ADDI 5
        // PC=0. Reg0 starts at 0. Result should be 5.
        #(CLK_PERIOD); 
        $display("Time: %0t | PC: %d | Instruction: %h | ALU Out: %d | Reg0 (Port A): %d", 
                 $time, uut.pc_current, uut.instruction, debug_alu_out, debug_port_a);

        // 2. Execute ADDI 10
        // PC=1. Reg0 is 5. Result should be 5 + 10 = 15.
        #(CLK_PERIOD); 
        $display("Time: %0t | PC: %d | Instruction: %h | ALU Out: %d | Reg0 (Port A): %d", 
                 $time, uut.pc_current, uut.instruction, debug_alu_out, debug_port_a);

        // 3. Execute SUBI 2
        // PC=2. Reg0 is 15. Result should be 15 - 2 = 13.
        #(CLK_PERIOD); 
        $display("Time: %0t | PC: %d | Instruction: %h | ALU Out: %d | Reg0 (Port A): %d", 
                 $time, uut.pc_current, uut.instruction, debug_alu_out, debug_port_a);

        // 4. Execute NOOP
        #(CLK_PERIOD); 
        $display("Time: %0t | PC: %d | Instruction: %h | Final Reg0 Value: %d", 
                 $time, uut.pc_current, uut.instruction, debug_port_a);

        // --- Final Check ---
        if (debug_port_a === 13) 
            $display("SUCCESS: CPU calculated 0 + 5 + 10 - 2 = 13 correctly.");
        else
            $display("FAILURE: Expected 13, got %d", debug_port_a);

        $finish;
    end

endmodule