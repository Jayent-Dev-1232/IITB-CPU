module pc_update_logic(
    input wire [5:0] A0, A1,
    output wire [5:0] Y0, Y1
);
    
    six_bit_adder f1 (.a(A0), .b(6'b000001), .sum(Y0));
    six_bit_adder f2 (.a(Y0), .b(A1), .sum(Y1));
endmodule