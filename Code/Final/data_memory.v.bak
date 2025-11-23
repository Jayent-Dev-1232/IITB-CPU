module data_memory (
    input  wire        clk,
    input  wire [3:0]  addr,
    input  wire [7:0]  data_in,
    input  wire        write_enable,
    output wire [7:0]  data_out,
    output wire [127:0] data_led
);

    reg [7:0] mem [0:15];

    initial begin
        mem[0]  = 8'b00000111;
        mem[1]  = 8'b00000011;
        mem[2]  = 8'b00000010;
        mem[3]  = 8'b00000001;
        mem[4]  = 8'b00000110;
        mem[5]  = 8'b00000100;
        mem[6]  = 8'b00000101;
        mem[7]  = 8'b00001000;
        mem[8]  = 8'b00000111;
        mem[9]  = 8'b00000000;
        mem[10] = 8'b00000000;
        mem[11] = 8'b00000000;
        mem[12] = 8'b00000000;
        mem[13] = 8'b00000000;
        mem[14] = 8'b00000000;
        mem[15] = 8'b00000000;
    end

    always @(posedge clk) begin
        if (write_enable)
            mem[addr] <= data_in;
    end

    assign data_out = mem[addr];
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : LED_PACK
            assign data_led[(i*8)+7 : (i*8)] = mem[i];
        end
    endgenerate

endmodule