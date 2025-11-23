module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [1:0] op,
    output reg  [7:0] result,
    output reg        carry,
    output reg        overflow,
    output wire       negative,
    output wire       zero
);

    reg [7:0] a_u;
    reg [7:0] b_u;
    reg [7:0] res_u;

    reg carry_s;
    reg ov_s;
    // 9-bit temp for add/sub
    reg [8:0] tmp;

    always @(*) begin
        a_u = a;
        b_u = b;

        carry_s = 0;
        ov_s    = 0;
        res_u   = 0;

        case(op)
            2'b00: begin
                carry_s = a[7];
                res_u   = a_u << 1;
            end

            2'b01: begin
                carry_s = a[0];
                res_u   = a_u >> 1;
            end

            2'b10: begin
                tmp    = {1'b0, a_u} + {1'b0, b_u};
                res_u  = tmp[7:0];
                carry_s = tmp[8];

                // signed overflow
                ov_s = (a[7] ^ tmp[7]) & ~(a[7] ^ b[7]);
            end

            2'b11: begin
                tmp    = {1'b0, a_u} - {1'b0, b_u};
                res_u  = tmp[7:0];
                carry_s = tmp[8];
                ov_s = (a[7] ^ b[7]) & (a[7] ^ tmp[7]);
            end

            default: begin
                res_u = 8'b00000000;
            end
        endcase
    end

    always @(*) begin
        result   = res_u;
        carry    = carry_s;
        overflow = ov_s;
    end

    assign negative = res_u[7];
    assign zero     = (res_u == 8'b00000000);

endmodule