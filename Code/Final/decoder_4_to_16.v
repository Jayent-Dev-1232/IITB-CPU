module decoder_4_to_16 (
    input  wire [3:0] w,
    input  wire       en,
    output reg  [15:0] y
);

    always @(*) begin
        if (en == 1'b1)
            y = (16'b0000_0000_0000_0001 << w);
        else
            y = 16'b0000_0000_0000_0000;
    end

endmodule
