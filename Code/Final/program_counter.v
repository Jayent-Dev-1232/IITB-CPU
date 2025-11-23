module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_write_en,
    input  wire        pc_mux,
    input  wire [5:0]  offset_val,
    output wire [5:0]  pc_out
);

    reg [5:0] pc_temp;

    assign pc_out = pc_temp;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_temp <= 6'b000000;
        end else begin
            if (pc_mux == 1'b1 && pc_write_en == 1'b1) begin
                pc_temp <= pc_temp + offset_val + 6'b000001;
            end else if (pc_write_en == 1'b1) begin
                pc_temp <= pc_temp + 6'b000001;
            end
        end
    end

endmodule