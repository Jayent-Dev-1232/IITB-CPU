// Auto-generated Verilog Control Decoder
module control_unit(
    input  [26:0] opcode_in,
    input  [3:0] break_flag,
    output [17:0] control
);

    wire [22:0] opcode = opcode_in[22:0];
    wire Y0 = opcode_in[26];
    wire Y1 = opcode_in[25];
    wire X0 = opcode_in[24];
    wire X1 = opcode_in[23];

    // One-hot opcode mapping
    localparam NOOP = 0;
    localparam INPUTC = 1;
    localparam INPUTCF = 2;
    localparam INPUTD = 3;
    localparam INPUTDF = 4;
    localparam MOVE = 5;
    localparam LOADI_LOADP = 6;
    localparam ADD = 7;
    localparam ADDI = 8;
    localparam SUB = 9;
    localparam SUBI = 10;
    localparam LOAD = 11;
    localparam LOADF = 12;
    localparam STORE = 13;
    localparam STOREF = 14;
    localparam SHIFTL = 15;
    localparam SHIFTR = 16;
    localparam CMP = 17;
    localparam JUMP = 18;
    localparam BRE_BRZ = 19;
    localparam BRNE_BRNZ = 20;
    localparam BRG = 21;
    localparam BRGE = 22;

    // Control signal equations
    assign control[0]  = opcode[INPUTC] | opcode[INPUTCF]; // IMEM_WRITE_ENABLE
    assign control[1]  = opcode[JUMP] | (opcode[BRE_BRZ] & break_flag[0]) | (opcode[BRNE_BRNZ] & break_flag[1]) | (opcode[BRG] & break_flag[2]) | (opcode[BRGE] & break_flag[3]); // PROGRAM_COUNTER_MUX
    assign control[2]  = 1'b1; // PROGRAM_WRITE_ENABLE
	 assign control[3] = ((opcode[INPUTCF] | opcode[INPUTDF] | opcode[ADD] | opcode[ADDI] | opcode[SUB] | opcode[SUBI] | opcode[SHIFTL] | opcode[SHIFTR] | opcode[CMP]) & X1) | ((opcode[MOVE] | opcode[LOADF] | opcode[STOREF]) & Y1); // REGISTERS_PORT0_SELECT1

    assign control[4] = ((opcode[INPUTCF] | opcode[INPUTDF] | opcode[ADD] | opcode[ADDI] | opcode[SUB] | opcode[SUBI] | opcode[SHIFTL] | opcode[SHIFTR] | opcode[CMP]) & X0) | ((opcode[MOVE] | opcode[LOADF] | opcode[STOREF]) & Y0); // REGISTERS_PORT0_SELECT0

    assign control[5] = ((opcode[STORE] | opcode[STOREF]) & X1) | ((opcode[ADD] | opcode[SUB] | opcode[CMP]) & Y1); // REGISTERS_PORT1_SELECT1

    assign control[6] = ((opcode[STORE] | opcode[STOREF]) & X0) | ((opcode[ADD] | opcode[SUB] | opcode[CMP]) & Y0); // REGISTERS_PORT1_SELECT0

    assign control[7] = ((opcode[MOVE] | opcode[LOADI_LOADP] | opcode[ADD] | opcode[ADDI] | opcode[SUB] | opcode[SUBI] | opcode[LOAD] | opcode[LOADF] | opcode[SHIFTL] | opcode[SHIFTR]) & X1); // REGISTERS_WRITE_SELECT1

    assign control[8] = ((opcode[MOVE] | opcode[LOADI_LOADP] | opcode[ADD] | opcode[ADDI] | opcode[SUB] | opcode[SUBI] | opcode[LOAD] | opcode[LOADF] | opcode[SHIFTL] | opcode[SHIFTR]) & X0); // REGISTERS_WRITE_SELECT0

    assign control[9]  = opcode[MOVE] | opcode[LOADI_LOADP] | opcode[ADD] | opcode[ADDI] | opcode[SUB] | opcode[SUBI] | opcode[LOAD] | opcode[LOADF] | opcode[SHIFTL] | opcode[SHIFTR]; // REGISTERS_WRITE_ENABLE
    assign control[10] = opcode[INPUTCF] | opcode[INPUTDF] | opcode[MOVE] | opcode[ADDI] | opcode[SUBI] | opcode[LOADF] | opcode[STOREF]; // ALU_SOURCE_MUX
    assign control[11] = opcode[INPUTCF] | opcode[INPUTDF] | opcode[MOVE] | opcode[ADD] | opcode[ADDI] | opcode[SUB] | opcode[SUBI] | opcode[LOADF] | opcode[STOREF] | opcode[CMP]; // ALU_SELECT1
    assign control[12] = opcode[SUB] | opcode[SUBI] | opcode[SHIFTR] | opcode[CMP]; // ALU_SELECT0
    assign control[13] = opcode[ADD] | opcode[ADDI] | opcode[SUB] | opcode[SUBI] | opcode[SHIFTL] | opcode[SHIFTR] | opcode[CMP]; // FLAGS_WRITE_ENABLE
    assign control[14] = opcode[INPUTC] | opcode[INPUTD] | opcode[LOADI_LOADP] | opcode[LOAD] | opcode[STORE]; // ALU_RESET_MUX
    assign control[15] = opcode[INPUTD] | opcode[INPUTDF]; // DMEM_INPUT_MUX
    assign control[16] = opcode[INPUTD] | opcode[INPUTDF] | opcode[STORE] | opcode[STOREF]; // DMEM_WRITE_ENABLE
    assign control[17] = opcode[LOAD] | opcode[LOADF]; // REG_WRITEBACK_MUX

endmodule
