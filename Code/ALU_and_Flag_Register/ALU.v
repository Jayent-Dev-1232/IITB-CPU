module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module flag_calculator (
    input wire [7:0] I,
    output wire zero,
    output wire negative
);
    assign zero = ~(I[0] | I[1] | I[2] | I[3] | I[4] | I[5] | I[6] | I[7]);
    assign negative = I[7];
endmodule

module two_in_mux (
    input wire a,
    input wire b,
    input wire sel,
    output wire y
);
    assign y = (sel == 1'b0) ? b : a;
endmodule

module eight_in_mux (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire sel,
    output wire [7:0] y
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : mux_loop
            two_in_mux mux_inst (
                .a(a[i]),
                .b(b[i]),
                .sel(sel),
                .y(y[i])
            );
        end
    endgenerate
    
endmodule

module bit_shifter (
    input wire select,
    input wire [7:0] I,
    output wire [7:0] O,
    output wire shift_out
);
    two_in_mux m0 (.a(I[0]), .b(I[7]), .sel(select), .y(shift_out));
    two_in_mux m1 (.a(I[1]), .b(1'b0), .sel(select), .y(O[0]));
    two_in_mux m2 (.a(I[2]), .b(I[0]), .sel(select), .y(O[1]));
    two_in_mux m3 (.a(I[3]), .b(I[1]), .sel(select), .y(O[2]));
    two_in_mux m4 (.a(I[4]), .b(I[2]), .sel(select), .y(O[3]));
    two_in_mux m5 (.a(I[5]), .b(I[3]), .sel(select), .y(O[4]));
    two_in_mux m6 (.a(I[6]), .b(I[4]), .sel(select), .y(O[5]));
    two_in_mux m7 (.a(I[7]), .b(I[5]), .sel(select), .y(O[6]));
    two_in_mux m8 (.a(1'b0), .b(I[6]), .sel(select), .y(O[7]));
endmodule

module bit_adder (
    input  wire [7:0] X,
    input  wire [7:0] Y,
    input  wire add_sub,
    output wire [7:0] S,
    output wire overflow,
    output wire carry
);

    wire [7:0] Yxor;
    wire [8:0] C;
    assign C[0] = add_sub;
    assign Yxor = Y ^ {8{add_sub}};

    full_adder fa0 (.a(X[0]), .b(Yxor[0]), .cin(C[0]), .sum(S[0]), .cout(C[1]));
    full_adder fa1 (.a(X[1]), .b(Yxor[1]), .cin(C[1]), .sum(S[1]), .cout(C[2]));
    full_adder fa2 (.a(X[2]), .b(Yxor[2]), .cin(C[2]), .sum(S[2]), .cout(C[3]));
    full_adder fa3 (.a(X[3]), .b(Yxor[3]), .cin(C[3]), .sum(S[3]), .cout(C[4]));
    full_adder fa4 (.a(X[4]), .b(Yxor[4]), .cin(C[4]), .sum(S[4]), .cout(C[5]));
    full_adder fa5 (.a(X[5]), .b(Yxor[5]), .cin(C[5]), .sum(S[5]), .cout(C[6]));
    full_adder fa6 (.a(X[6]), .b(Yxor[6]), .cin(C[6]), .sum(S[6]), .cout(C[7]));
    full_adder fa7 (.a(X[7]), .b(Yxor[7]), .cin(C[7]), .sum(S[7]), .cout(C[8]));

    assign carry = C[8];
    assign overflow = C[7] ^ C[8];

endmodule

module ALU (
    input wire [1:0]ALU_select,
    input wire [7:0]A,
    input wire [7:0]B,
    output wire [7:0]ALU_result,
    output wire carry,
    output wire overflow,
    output wire zero,
    output wire negative
);
    wire [7:0]adder_result;
    wire adder_carry;
    wire adder_overflow;
    wire [7:0]shifter_result;
    wire shifter_carry;

    bit_shifter shifter (
        .select(ALU_select[0]),
        .I(A),
        .O(shifter_result),
        .shift_out(shifter_carry)
    );
    bit_adder adder (
        .X(A),
        .Y(B),
        .add_sub(ALU_select[0]),
        .S(adder_result),
        .overflow(adder_overflow),
        .carry(adder_carry)
    );
    eight_in_mux result_mux (
        .a(shifter_result),
        .b(adder_result),
        .sel(ALU_select[1]),
        .y(ALU_result)
    );
    two_in_mux carry_mux (
        .a(adder_carry),
        .b(shifter_carry),
        .sel(ALU_select[1]),
        .y(carry)
    );
    two_in_mux overflow_mux (
        .a(adder_overflow),
        .b(1'b0),
        .sel(ALU_select[1]),
        .y(overflow)
    );
    flag_calculator flag_calc (
        .I(ALU_result),
        .zero(zero),
        .negative(negative)
    );
endmodule

module dff_async (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule

module flag_register (
    input  wire clk,
    input  wire rst_n,
    input  wire write_enable,

    input  wire carry_in,
    input  wire overflow_in,
    input  wire negative_in,
    input  wire zero_in,

    output wire carry_flag,
    output wire overflow_flag,
    output wire negative_flag,
    output wire zero_flag
);

    wire d_carry;
    wire d_overflow;
    wire d_negative;
    wire d_zero;

    two_in_mux M0 (.a(carry_flag),    .b(carry_in),    .sel(write_enable), .y(d_carry));
    two_in_mux M1 (.a(overflow_flag), .b(overflow_in), .sel(write_enable), .y(d_overflow));
    two_in_mux M2 (.a(negative_flag), .b(negative_in), .sel(write_enable), .y(d_negative));
    two_in_mux M3 (.a(zero_flag),     .b(zero_in),     .sel(write_enable), .y(d_zero));
    dff_async FF0 (.clk(clk), .rst_n(rst_n), .d(d_carry),    .q(carry_flag));
    dff_async FF1 (.clk(clk), .rst_n(rst_n), .d(d_overflow), .q(overflow_flag));
    dff_async FF2 (.clk(clk), .rst_n(rst_n), .d(d_negative), .q(negative_flag));
    dff_async FF3 (.clk(clk), .rst_n(rst_n), .d(d_zero),     .q(zero_flag));

endmodule


`timescale 1ns / 1ps

module tb_alu_flag_register;

    // Clock and reset
    reg clk;
    reg rst_n;
    
    // ALU inputs
    reg [1:0] ALU_select;
    reg [7:0] A;
    reg [7:0] B;
    
    // ALU outputs
    wire [7:0] ALU_result;
    wire carry_alu;
    wire overflow_alu;
    wire zero_alu;
    wire negative_alu;
    
    // Flag register inputs/outputs
    reg write_enable;
    wire carry_flag;
    wire overflow_flag;
    wire negative_flag;
    wire zero_flag;
    
    // Instantiate ALU
    ALU uut_alu (
        .ALU_select(ALU_select),
        .A(A),
        .B(B),
        .ALU_result(ALU_result),
        .carry(carry_alu),
        .overflow(overflow_alu),
        .zero(zero_alu),
        .negative(negative_alu)
    );
    
    // Instantiate Flag Register
    flag_register uut_flag_reg (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable),
        .carry_in(carry_alu),
        .overflow_in(overflow_alu),
        .negative_in(negative_alu),
        .zero_in(zero_alu),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .negative_flag(negative_flag),
        .zero_flag(zero_flag)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 0;
        ALU_select = 2'b00;
        A = 8'h00;
        B = 8'h00;
        write_enable = 0;
        
        // VCD dump for waveform viewing
        $dumpfile("alu_flag_tb.vcd");
        $dumpvars(0, tb_alu_flag_register);
        
        // Apply reset
        #10 rst_n = 1;
        #10;
        
        $display("===== ALU and Flag Register Test =====\n");
        
        // Test 1: Addition (ALU_select = 2'b10)
        $display("Test 1: Addition Operations");
        ALU_select = 2'b10;
        
        A = 8'h0F; B = 8'h01; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("ADD: %h + %h = %h | C=%b V=%b Z=%b N=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, B, ALU_result, carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        A = 8'hFF; B = 8'h01; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("ADD: %h + %h = %h | C=%b V=%b Z=%b N=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, B, ALU_result, carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        A = 8'h7F; B = 8'h01; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("ADD: %h + %h = %h | C=%b V=%b Z=%b N=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, B, ALU_result, carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        // Test 2: Subtraction (ALU_select = 2'b11)
        $display("\nTest 2: Subtraction Operations");
        ALU_select = 2'b11;
        
        A = 8'h10; B = 8'h05; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("SUB: %h - %h = %h | C=%b V=%b Z=%b N=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, B, ALU_result, carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        A = 8'h05; B = 8'h05; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("SUB: %h - %h = %h | C=%b V=%b Z=%b N=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, B, ALU_result, carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        A = 8'h00; B = 8'h01; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("SUB: %h - %h = %h | C=%b V=%b Z=%b N=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, B, ALU_result, carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        // Test 3: Shift Right (ALU_select = 2'b00)
        $display("\nTest 3: Shift Right Operations");
        ALU_select = 2'b00;
        
        A = 8'b10110101; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("SHR: %b >> 1 = %b | shift_out=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, ALU_result, carry_alu, carry_flag, overflow_flag, zero_flag, negative_flag);
        
        A = 8'b00000001; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("SHR: %b >> 1 = %b | shift_out=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, ALU_result, carry_alu, carry_flag, overflow_flag, zero_flag, negative_flag);
        
        // Test 4: Shift Left (ALU_select = 2'b01)
        $display("\nTest 4: Shift Left Operations");
        ALU_select = 2'b01;
        
        A = 8'b10110101; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("SHL: %b << 1 = %b | shift_out=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, ALU_result, carry_alu, carry_flag, overflow_flag, zero_flag, negative_flag);
        
        A = 8'b10000000; #10; write_enable = 1; #10; write_enable = 0; #10;
        $display("SHL: %b << 1 = %b | shift_out=%b | Flags: C=%b V=%b Z=%b N=%b",
                 A, ALU_result, carry_alu, carry_flag, overflow_flag, zero_flag, negative_flag);
        
        // Test 5: Flag register persistence (write_enable = 0)
        $display("\nTest 5: Flag Register Persistence Test");
        ALU_select = 2'b10;
        A = 8'hAA; B = 8'h55; write_enable = 0; #20;
        $display("New ALU result without write: ALU flags C=%b V=%b Z=%b N=%b | Stored flags C=%b V=%b Z=%b N=%b",
                 carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        // Test 6: Reset test
        $display("\nTest 6: Reset Test");
        rst_n = 0; #20; rst_n = 1; #10;
        $display("After reset: Flags C=%b V=%b Z=%b N=%b",
                 carry_flag, overflow_flag, zero_flag, negative_flag);
        
        $display("\n===== Test Complete =====");
        #50;
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("Time=%0t | ALU_sel=%b A=%h B=%h | Result=%h | ALU: C=%b V=%b Z=%b N=%b | REG: C=%b V=%b Z=%b N=%b | WE=%b",
                 $time, ALU_select, A, B, ALU_result, 
                 carry_alu, overflow_alu, zero_alu, negative_alu,
                 carry_flag, overflow_flag, zero_flag, negative_flag,
                 write_enable);
    end

endmodule