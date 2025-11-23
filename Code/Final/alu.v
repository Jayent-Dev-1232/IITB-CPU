module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [1:0] ALU_select,
    output reg  [7:0] ALU_result,
    output reg        carry,
    output reg        overflow,
    output wire       negative,
    output wire       zero
);

    reg [7:0] a_temp; //temp memory
    reg [7:0] b_temp;
    reg [7:0] res_temp;

    reg signed_carry; //signed carry
    reg signed_overflow; //signed overflow
    reg [8:0] tmp;

    always @(*) begin
        a_temp = a; //assign inputs
        b_temp = b;

        signed_carry = 0;
        signed_overflow    = 0;
        res_temp   = 0; //

        case(ALU_select)
            2'b00: begin
                signed_carry = a[7];
                res_temp   = a_temp << 1;
            end

            2'b01: begin
                signed_carry = a[0];
                res_temp   = a_temp >> 1;
            end

            2'b10: begin
                tmp    = {1'b0, a_temp} + {1'b0, b_temp}; //concatenating to get unsigned sum
                res_temp  = tmp[7:0];
                signed_carry = tmp[8];

                signed_overflow = (a[7] ^ tmp[7]) & ~(a[7] ^ b[7]);
            end

            2'b11: begin
                tmp    = {1'b0, a_temp} - {1'b0, b_temp};
                res_temp  = tmp[7:0];
                signed_carry = tmp[8];
                signed_overflow = (a[7] ^ b[7]) & (a[7] ^ tmp[7]);
            end

            default: begin
                res_temp = 8'b00000000;
            end
        endcase
    end

    always @(*) begin
        ALU_result   = res_temp;
        carry    = signed_carry;
        overflow = signed_overflow;
    end

    assign negative = res_temp[7]; // continuous/blocking assignment
    assign zero     = (res_temp == 8'b00000000);

endmodule