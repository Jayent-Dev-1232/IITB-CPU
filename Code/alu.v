module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [1:0] ALU_select, // c12, c13
    output reg  [7:0] ALU_result,
    output reg        carry,
    output reg        overflow,
    output wire       negative,
    output wire       zero
);

    reg [7:0] a_temp; //temp memory
    reg [7:0] b_temp;
    reg [7:0] res_temp;

    reg carry_out; // carry from the addition/subtraction operation
    reg overflow_out; // overflow from the addition/subtraction operation
    reg [8:0] temp_result;

    always @(*) begin
        a_temp = a; //assign inputs
        b_temp = b;

        carry_out = 0;
        overflow_out    = 0;
        res_temp   = 0; //

        case(ALU_select)
            2'b00: begin
                carry_out = a[7];
                res_temp   = a_temp << 1;
            end

            2'b01: begin
                carry_out = a[0];
                res_temp   = a_temp >> 1;
            end

            2'b10: begin
                temp_result    = {1'b0, a_temp} + {1'b0, b_temp}; //concatenating to get unsigned sum
                res_temp  = temp_result[7:0];
                carry_out = temp_result[8];

                overflow_out = (a_temp[7] ^ temp_result[7]) & ~(a_temp[7] ^ b_temp[7]);
            end

            2'b11: begin
                temp_result    = {1'b0, a_temp} - {1'b0, b_temp};
                res_temp  = temp_result[7:0];
                carry_out = temp_result[8];
                overflow_out = (a_temp[7] ^ b_temp[7]) & (a_temp[7] ^ temp_result[7]);
            end

            default: begin
                res_temp = 8'b00000000;
            end
        endcase
    end

    always @(*) begin
        ALU_result   = res_temp;
        carry    = carry_out;
        overflow = overflow_out;
    end

    assign negative = res_temp[7]; // continuous/blocking assignment
    assign zero     = (res_temp == 8'b00000000);

endmodule