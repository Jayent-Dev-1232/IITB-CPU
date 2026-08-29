module control_unit (
    input  wire [26:0] opcode,
    input  wire [3:0]  flags,

    output reg         imem_we, // write enable of code memory
    output reg         pc_mux, // select of PC MUX
    output reg         pc_we, // write enable of PC
    output reg  [1:0]  reg_port0_sel,
    output reg  [1:0]  reg_port1_sel,
    output reg  [1:0]  reg_write_sel,
    output reg         reg_write_en,
    output reg         alu_src_mux, // select of ALU Source MUX
    output reg  [1:0]  alu_select, // select of ALU operation
    output reg         flag_write_en,
    output reg         alu_result_mux,
    output reg         dmem_input_mux,
    output reg         dmem_write_en,
    output reg         reg_writeback_mux,

    output wire [4:0]  opi_o
);

    wire [22:0] op  = opcode[22:0]; // 23 unique opcodes
    wire [1:0]  x   = opcode[26:25];
    wire [1:0]  y   = opcode[24:23];

    wire [30:0] inp = {8'b00000000, op};
    wire [4:0]  opi;

    enc_31_to_5 encoder_inst (
        .in_vec(inp),
        .code(opi)
    );

    always @(*) begin
        imem_we          = 1'b0;
        pc_mux           = 1'b0;
        pc_we            = 1'b1;
        reg_port0_sel    = 2'b00;
        reg_port1_sel    = 2'b00;
        reg_write_sel    = 2'b00;
        reg_write_en     = 1'b0;
        alu_src_mux      = 1'b0;
        alu_select           = 2'b00;
        flag_write_en    = 1'b0;
        alu_result_mux   = 1'b0;
        dmem_input_mux   = 1'b0;
        dmem_write_en    = 1'b0;
        reg_writeback_mux = 1'b0;

        case (opi)

            5'b00000: begin end   // NOOP

            5'b00001: begin       // INPUTC
                imem_we        = 1'b1;
                pc_we          = 1'b1;
                alu_result_mux = 1'b1;
            end

            5'b00010: begin       // INPUTCF
                imem_we     = 1'b1;
                pc_we       = 1'b1;
                reg_port0_sel = x;
                alu_src_mux = 1'b1;
                alu_select      = 2'b10;
            end

            5'b00011: begin       // INPUTD
                pc_we          = 1'b1;
                alu_result_mux = 1'b1;
                dmem_input_mux = 1'b1;
                dmem_write_en  = 1'b1;
            end

            5'b00100: begin       // INPUTDF
                reg_port0_sel = x;
                alu_src_mux   = 1'b1;
                alu_select        = 2'b10;
                dmem_input_mux = 1'b1;
                dmem_write_en  = 1'b1;
            end

            5'b00101: begin       // MOVE
                reg_port0_sel = y;
                reg_write_sel = x;
                reg_write_en  = 1'b1;
                alu_select        = 2'b10;
            end

            5'b00110: begin       // LOADI / LOADP
                reg_write_sel  = x;
                reg_write_en   = 1'b1;
                alu_result_mux = 1'b1;
            end

            5'b00111: begin       // ADD
                reg_port0_sel = x;
                reg_port1_sel = y;
                reg_write_sel = x;
                reg_write_en  = 1'b1;
                alu_select        = 2'b10;
                flag_write_en = 1'b1;
            end

            5'b01000: begin       // ADDI
                reg_port0_sel = x;
                reg_write_sel = x;
                reg_write_en  = 1'b1;
                alu_src_mux   = 1'b1;
                alu_select        = 2'b10;
                flag_write_en = 1'b1;
            end

            5'b01001: begin       // SUB
                reg_port0_sel = x;
                reg_port1_sel = y;
                reg_write_sel = x;
                reg_write_en  = 1'b1;
                alu_select        = 2'b11;
                flag_write_en = 1'b1;
            end

            5'b01010: begin       // SUBI
                reg_port0_sel = x;
                reg_write_sel = x;
                reg_write_en  = 1'b1;
                alu_src_mux   = 1'b1;
                alu_select        = 2'b11;
                flag_write_en = 1'b1;
            end

            5'b01011: begin       // LOAD
                reg_write_sel   = x;
                reg_write_en    = 1'b1;
                alu_result_mux  = 1'b1;
                reg_writeback_mux = 1'b1;
            end

            5'b01100: begin       // LOADF
                reg_port0_sel   = y;
                reg_write_sel   = x;
                reg_write_en    = 1'b1;
                alu_src_mux     = 1'b1;
                alu_select          = 2'b10;
                reg_writeback_mux = 1'b1;
            end

            5'b01101: begin       // STORE
                reg_port1_sel = x;
                alu_result_mux = 1'b0;
                dmem_write_en  = 1'b1;
            end

            5'b01110: begin       // STOREF
                reg_port0_sel = y;
                reg_port1_sel = x;
                alu_src_mux   = 1'b1;
                alu_select        = 2'b10;
                dmem_write_en = 1'b1;
            end

            5'b01111: begin       // SHIFTL
                reg_port0_sel = x;
                reg_write_sel = x;
                reg_write_en  = 1'b1;
                flag_write_en = 1'b1;
            end

            5'b10000: begin       // SHIFTR
                reg_port0_sel = x;
                reg_write_sel = x;
                reg_write_en  = 1'b1;
                flag_write_en = 1'b1;
                alu_select        = 2'b01;
            end

            5'b10001: begin       // CMP
                reg_port0_sel = x;
                reg_port1_sel = y;
                alu_select        = 2'b11;
                flag_write_en = 1'b1;
            end

            5'b10010: begin       // JUMP
                pc_mux = 1'b1;
            end

            5'b10011: begin       // BRE / BRZ
                pc_mux = flags[0];
            end

            5'b10100: begin       // BRNE / BRNZ
                pc_mux = ~flags[0];
            end

            5'b10101: begin       // BRG
                pc_mux = (~flags[0]) & (flags[1] ~^ flags[2]);
            end

            5'b10110: begin       // BRGE
                pc_mux = (flags[1] ~^ flags[2]);
            end

            default: begin
                
            end
        endcase
    end

    assign opi_o = opi;

endmodule