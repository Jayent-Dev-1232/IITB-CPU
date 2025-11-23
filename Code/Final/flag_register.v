module flag_register (
    input  wire negative,
    input  wire overflow,
    input  wire carry,
    input  wire zero,
    output wire [3:0] y,
    input  wire clk,
    input  wire flag_write_en
);

    reg carryflag_temp      = 1'b0;
    reg negativeflag_temp   = 1'b0;
    reg overflowflag_temp   = 1'b0;
    reg zeroflag_temp       = 1'b0;

    always @(negedge clk) begin
        if (flag_write_en == 1'b1) begin
            carryflag_temp    <= carry;
            negativeflag_temp <= negative;
            overflowflag_temp <= overflow;
            zeroflag_temp     <= zero;
        end
    end

    assign y[2] = overflowflag_temp;
    assign y[3] = carryflag_temp;
    assign y[0] = zeroflag_temp;
    assign y[1] = negativeflag_temp;

endmodule