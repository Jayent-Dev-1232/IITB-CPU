module dec_1_to_2 (
    input  wire w,
    input  wire en,
    output reg  [1:0] y
);

    always @(*) begin
        if (en == 1'b0)
            y = 2'b00;
        else if (w == 1'b0)
            y = 2'b01;
        else
            y = 2'b10;
    end

endmodule