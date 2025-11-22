module code_memory (
    input wire [15:0] data_in,
    input wire [5:0] write_select,
    input wire [5:0] read_select,
    input wire select,
    output wire [15:0] data_out
);
    reg [15:0] memory_array [0:63];
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
        memory_array[i] = 16'b0;
    end

    always @(*) begin
        if (select) begin
            memory_array[write_select] = data_in;
        end
    end

    assign data_out = memory_array[read_select];
endmodule