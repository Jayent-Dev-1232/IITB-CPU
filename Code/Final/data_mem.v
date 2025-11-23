module data_mem (
    input  wire        clk,
    input  wire [3:0]  address,
    input  wire [7:0]  data_in,
    input  wire        write_en,
    output wire [7:0]  data_out,
    output wire [127:0] data_output
);

    reg [7:0] memory_array [0:15];
	 integer j;

    initial begin
        memory_array[0]  = 8'b00000111;
        memory_array[1]  = 8'b00000011;
        memory_array[2]  = 8'b00000010;
        memory_array[3]  = 8'b00000001;
        memory_array[4]  = 8'b00000110;
        memory_array[5]  = 8'b00000100;
        memory_array[6]  = 8'b00000101;
        memory_array[7]  = 8'b00001000;
        memory_array[8]  = 8'b00000111;
        for (j = 9; j < 16; j = j + 1)
			memory_array[j] = 8'b00000000;
    end

    always @(posedge clk) begin
        if (write_en)
            memory_array[address] <= data_in;
    end

    assign data_out = memory_array[address];
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : LED_PACK
            assign data_output[(i*8)+7 : (i*8)] = memory_array[i];
        end
    endgenerate

endmodule