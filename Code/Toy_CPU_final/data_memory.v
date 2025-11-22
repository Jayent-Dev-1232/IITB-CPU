module data_memory (
    input wire [7:0] data_in,
    input wire [3:0] write_select,
    input wire [3:0] read_select,
    input wire select,
    output wire [7:0] data_out
);
    reg [7:0] memory_array [0:15];
    integer i;
    initial begin
        for (i = 0; i < 15; i = i + 1)
        memory_array[i] = 8'b0;
    end

    always @(*) begin
        if (select) begin
            memory_array[write_select] = data_in;
        end
    end

    assign data_out = memory_array[read_select];
endmodule