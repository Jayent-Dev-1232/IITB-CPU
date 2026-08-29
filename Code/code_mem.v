module code_mem (
    input  wire        clk,
    input  wire [5:0]  read_address,
    output reg  [15:0] data_out,
    input  wire        write_en,
    input  wire [5:0]  write_address,
    input  wire [15:0] write_data
);

    reg [15:0] memory_array [0:63];
    integer i;

    initial begin
        memory_array[0]  = 16'b0000000000000000;
        memory_array[1]  = 16'b1110000000011110;

        for(i = 2; i < 32; i = i + 1)
            memory_array[i] = 16'b0000000000000000;

        memory_array[32] = 16'b0011000000000000;
        memory_array[33] = 16'b1000110000001000;
        memory_array[34] = 16'b0011010000000000;
        memory_array[35] = 16'b1101001100000000;
        memory_array[36] = 16'b1111001100001110;
        memory_array[37] = 16'b1000110000001000;
        memory_array[38] = 16'b0110110000000000;
        memory_array[39] = 16'b1101011100000000;
        memory_array[40] = 16'b1111001100001000;
        memory_array[41] = 16'b1001100100000000;
        memory_array[42] = 16'b1001110100000001;
        memory_array[43] = 16'b1101111000000000;
        memory_array[44] = 16'b1111001100000010;
        memory_array[45] = 16'b1011110100000000;
        memory_array[46] = 16'b1011100100000001;
        memory_array[47] = 16'b0101010000000001;
        memory_array[48] = 16'b1110000011110100;
        memory_array[49] = 16'b0101000000000001;
        memory_array[50] = 16'b1110000011101110;

        for(i = 51; i < 64; i = i + 1)
            memory_array[i] = 16'b0000000000000000;
    end

    always @(posedge clk) begin
        if (write_en)
            memory_array[write_address] <= write_data;
    end

    always @(*) begin
        data_out = memory_array[read_address];
    end

endmodule