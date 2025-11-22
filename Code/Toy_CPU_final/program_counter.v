module program_counter (
    input wire clk,
    input wire reset,
    input wire [5:0] A,
    input wire c3,
    output reg [5:0] Y
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Y <= 6'b000000;
        end
        else if (c3) begin
            Y <= A;
        end
    end
endmodule