module encoder_31_to_5 (
    input  wire [30:0] in_vec,
    output reg  [4:0]  code
);

    integer i;
    reg found;

    always @(*) begin
        found = 1'b0;
        code  = 5'b00000;

        for (i = 30; i >= 0; i = i - 1) begin
            if (!found && in_vec[i] == 1'b1) begin
                code  = i[4:0];
                found = 1'b1;
            end
        end
    end

endmodule