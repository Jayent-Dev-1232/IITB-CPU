module two_to_four_decoder (
    input wire En,
    input wire [1:0] A,
    output reg [3:0] Y
);
    always @(*) begin
        Y = 4'b0;
        if (En == 1'b1) begin
            Y[A] = 1'b1;
        end
    end
endmodule