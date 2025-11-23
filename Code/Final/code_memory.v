// code_memory.v : 64-word code memory with BIOS init (0..31) + USER (32..63)

module code_memory (
    input  wire        clk,
    input  wire [5:0]  addr,
    output reg  [15:0] data_out,
    input  wire        write_enable,
    input  wire [5:0]  write_addr,
    input  wire [15:0] write_data
);

    // 64 words of 16-bit memory
    reg [15:0] mem [0:63];
    integer i;

    // Initialize BIOS region (0..31) and USER code (32..63)
    initial begin
        mem[0]  = 16'b0000000000000000;   // default not provided in VHDL, set = 0
        mem[1]  = 16'b1110000000011110;

        mem[2]  = 16'b0000000000000000;
        mem[3]  = 16'b0000000000000000;
        mem[4]  = 16'b0000000000000000;
        mem[5]  = 16'b0000000000000000;
        mem[6]  = 16'b0000000000000000;
        mem[7]  = 16'b0000000000000000;
        mem[8]  = 16'b0000000000000000;
        mem[9]  = 16'b0000000000000000;
        mem[10] = 16'b0000000000000000;
        mem[11] = 16'b0000000000000000;
        mem[12] = 16'b0000000000000000;
        mem[13] = 16'b0000000000000000;
        mem[14] = 16'b0000000000000000;
        mem[15] = 16'b0000000000000000;
        mem[16] = 16'b0000000000000000;
        mem[17] = 16'b0000000000000000;
        mem[18] = 16'b0000000000000000;
        mem[19] = 16'b0000000000000000;
        mem[20] = 16'b0000000000000000;
        mem[21] = 16'b0000000000000000;
        mem[22] = 16'b0000000000000000;
        mem[23] = 16'b0000000000000000;
        mem[24] = 16'b0000000000000000;
        mem[25] = 16'b0000000000000000;
        mem[26] = 16'b0000000000000000;
        mem[27] = 16'b0000000000000000;
        mem[28] = 16'b0000000000000000;
        mem[29] = 16'b0000000000000000;
        mem[30] = 16'b0000000000000000;
        mem[31] = 16'b0000000000000000;

        mem[32] = 16'b0011000000000000;
        mem[33] = 16'b1000110000001000;
        mem[34] = 16'b0011010000000000;
        mem[35] = 16'b1101001100000000;
        mem[36] = 16'b1111001100001110;
        mem[37] = 16'b1000110000001000;
        mem[38] = 16'b0110110000000000;
        mem[39] = 16'b1101011100000000;
        mem[40] = 16'b1111001100001000;
        mem[41] = 16'b1001100100000000;
        mem[42] = 16'b1001110100000001;
        mem[43] = 16'b1101111000000000;
        mem[44] = 16'b1111001100000010;
        mem[45] = 16'b1011110100000000;
        mem[46] = 16'b1011100100000001;
        mem[47] = 16'b0101010000000001;
        mem[48] = 16'b1110000011110100;
        mem[49] = 16'b0101000000000001;
        mem[50] = 16'b1110000011101110;

        for(i = 51; i < 64; i = i + 1)
            mem[i] = 16'b0000000000000000;
    end

    // Write operation (synchronous)
    always @(posedge clk) begin
        if (write_enable)
            mem[write_addr] <= write_data;
    end

    // Read operation (asynchronous)
    always @(*) begin
        data_out = mem[addr];
    end

endmodule