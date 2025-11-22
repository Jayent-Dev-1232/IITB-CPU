module four_to_sixteen_decoder (
    input wire En,
    input wire [3:0] A,
    output reg [15:0] Y
);
    always @(*) begin
        Y = 16'b0;
        if (En == 1'b1) begin
            Y[A] = 1'b1;
        end
    end
endmodule