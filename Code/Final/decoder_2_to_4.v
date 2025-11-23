module decoder_2_to_4 (
    input  wire [1:0] w,
    input  wire       en,
    output reg  [3:0] y
);

    always @(*) begin
        if (en == 1'b1)
            y = (4'b0001 << w);   // same as VHDL: 1 sll w
        else
            y = 4'b0000;
    end

endmodule