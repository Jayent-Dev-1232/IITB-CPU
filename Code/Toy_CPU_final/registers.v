module registers (
    input wire clk,
    input wire write_en,
    input wire reset,
    input wire [7:0] in_bus,
    output reg [7:0] A
);
    always @(posedge clk) begin
        if(reset) begin
            A <= 8'b00000000;
        end else if(write_en) begin
            A <= in_bus;
        end
    end
endmodule