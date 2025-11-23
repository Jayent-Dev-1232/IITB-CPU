module flag_reg (
    input  wire negative,
    input  wire overflow,
    input  wire carry,
    input  wire zero,
    output wire [3:0] y,
    input  wire clk,
    input  wire c14
);

    reg tcarryflag      = 1'b0;
    reg tnegativeflag   = 1'b0;
    reg toverflowflag   = 1'b0;
    reg tzeroflag       = 1'b0;

    always @(negedge clk) begin
        if (c14 == 1'b1) begin
            tcarryflag    <= carry;
            tnegativeflag <= negative;
            toverflowflag <= overflow;
            tzeroflag     <= zero;
        end
    end

    assign y[2] = toverflowflag;
    assign y[3] = tcarryflag;
    assign y[0] = tzeroflag;
    assign y[1] = tnegativeflag;

endmodule