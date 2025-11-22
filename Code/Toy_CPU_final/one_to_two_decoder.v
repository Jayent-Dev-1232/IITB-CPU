module one_to_two_decoder (
    input wire En,
    input wire A,
    output reg [1:0] Y
);
    always @(*) begin
        Y = 2'b0;
        if (En == 1'b1) begin
            Y[A] = 1'b1;
        end
    end
endmodule