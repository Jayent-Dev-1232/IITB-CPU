module opcode_decoder (
    input  wire [7:0] instr,
    output wire [26:0] opcode
);

    wire en1, en2, en3;

    wire [15:0] dec1_out;

    decoder_4_to_16 decoder_1 (
        .w(instr[7:4]),
        .en(1'b1),
        .y(dec1_out)
    );

    assign opcode[0]   = dec1_out[0];
    assign en1         = dec1_out[1];
    assign opcode[14:5]= dec1_out[11:2];
    assign en2         = dec1_out[12];
    assign opcode[18:17] = dec1_out[14:13];
    assign en3         = dec1_out[15];

    decoder_2_to_4 decoder_2 (
        .w(instr[1:0]),
        .en(en1),
        .y(opcode[4:1])
    );

    decoder_1_to_2 decoder_3 (
        .w(instr[0]),
        .en(en2),
        .y(opcode[16:15])
    );

    decoder_2_to_4 decoder_4 (
        .w(instr[1:0]),
        .en(en3),
        .y(opcode[22:19])
    );

    assign opcode[26:25] = instr[3:2];
    assign opcode[24:23] = instr[1:0];

endmodule