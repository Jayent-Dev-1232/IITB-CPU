module pc_update (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_we,
    input  wire        pc_mux,
    input  wire [5:0]  load_val,
    output wire [5:0]  pc_out
);

    reg [5:0] pc_reg;

    assign pc_out = pc_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 6'b000000;
        end else begin
            if (pc_mux == 1'b1 && pc_we == 1'b1) begin
                pc_reg <= pc_reg + load_val + 6'b000001;
            end else if (pc_we == 1'b1) begin
                pc_reg <= pc_reg + 6'b000001;
            end
        end
    end

endmodule