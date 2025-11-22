module registers (
    input wire clk,
    input wire write_en,
    input wire reset,
    input wire [7:0] in_bus,
    output reg [7:0] A
);
    always @(posedge clk) begin
        if(reset) begin
            A <= 8'b00000000;
        end else if(write_en) begin
            A <= in_bus;
        end
    end
endmodule

module four_in_mux (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [7:0] c,
    input wire [7:0] d,
    input wire [1:0] sel,
    output reg [7:0] y
);
    always @(*) begin
        case (sel)
            2'b00 : y = a;
            2'b01 : y = b;
            2'b10 : y = c;
            2'b11 : y = d;
            default: y = 8'b00000000;
        endcase
    end
endmodule

module register_file (
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire [1:0] write_sel, port_a_sel, port_b_sel,
    input wire [7:0] input_data,
    output wire [7:0] port_a_data, port_b_data
);
    wire [7:0] reg0_out, reg1_out, reg2_out, reg3_out;

    registers R0 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b00)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg0_out)
    );

    registers R1 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b01)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg1_out)
    );

    registers R2 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b10)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg2_out)
    );

    registers R3 (
        .clk(clk),
        .write_en(write_en & (write_sel == 2'b11)),
        .reset(reset),
        .in_bus(input_data),
        .A(reg3_out)
    );

    four_in_mux MUX_A (
        .a(reg0_out),
        .b(reg1_out),
        .c(reg2_out),
        .d(reg3_out),
        .sel(port_a_sel),
        .y(port_a_data)
    );

    four_in_mux MUX_B (
        .a(reg0_out),
        .b(reg1_out),
        .c(reg2_out),
        .d(reg3_out),
        .sel(port_b_sel),
        .y(port_b_data)
    );
endmodule

// // ========== CORRECTED TESTBENCH ==========

// `timescale 1ns / 1ps

// module tb_register_file;

//     // Inputs
//     reg clk;
//     reg reset;
//     reg write_en;
//     reg [1:0] write_sel;
//     reg [1:0] port_a_sel;
//     reg [1:0] port_b_sel;
//     reg [7:0] input_data;
    
//     // Outputs
//     wire [7:0] port_a_data;
//     wire [7:0] port_b_data;
    
//     // Instantiate the Unit Under Test (UUT)
//     register_file uut (
//         .clk(clk),
//         .reset(reset),
//         .write_en(write_en),
//         .write_sel(write_sel),
//         .port_a_sel(port_a_sel),
//         .port_b_sel(port_b_sel),
//         .input_data(input_data),
//         .port_a_data(port_a_data),
//         .port_b_data(port_b_data)
//     );
    
//     // Clock generation
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end
    
//     // Test stimulus
//     initial begin
//         // Initialize inputs
//         reset = 0;
//         write_en = 0;
//         write_sel = 2'b00;
//         port_a_sel = 2'b00;
//         port_b_sel = 2'b00;
//         input_data = 8'h00;
        
//         // VCD dump for waveform viewing
//         $dumpfile("register_file_tb.vcd");
//         $dumpvars(0, tb_register_file);
        
//         $display("===== Register File Test =====\n");
        
//         // Test 1: Reset all registers
//         $display("Test 1: Reset Test");
//         reset = 1;
//         #20;
//         reset = 0;
//         #10;
//         port_a_sel = 2'b00; port_b_sel = 2'b01; #10;
//         $display("After reset - R0: %h, R1: %h", port_a_data, port_b_data);
//         port_a_sel = 2'b10; port_b_sel = 2'b11; #10;
//         $display("After reset - R2: %h, R3: %h", port_a_data, port_b_data);
        
//         // Test 2: Write to individual registers
//         $display("\nTest 2: Write to Individual Registers");
//         write_en = 1;
        
//         write_sel = 2'b00; input_data = 8'hAA; #10;
//         port_a_sel = 2'b00; #1;
//         $display("Write %h to R0, Read R0: %h %s", 8'hAA, port_a_data, 
//                  (port_a_data === 8'hAA) ? "PASS" : "FAIL");
        
//         write_sel = 2'b01; input_data = 8'hBB; #10;
//         port_a_sel = 2'b01; #1;
//         $display("Write %h to R1, Read R1: %h %s", 8'hBB, port_a_data,
//                  (port_a_data === 8'hBB) ? "PASS" : "FAIL");
        
//         write_sel = 2'b10; input_data = 8'hCC; #10;
//         port_a_sel = 2'b10; #1;
//         $display("Write %h to R2, Read R2: %h %s", 8'hCC, port_a_data,
//                  (port_a_data === 8'hCC) ? "PASS" : "FAIL");
        
//         write_sel = 2'b11; input_data = 8'hDD; #10;
//         port_a_sel = 2'b11; #1;
//         $display("Write %h to R3, Read R3: %h %s", 8'hDD, port_a_data,
//                  (port_a_data === 8'hDD) ? "PASS" : "FAIL");
        
//         // Test 3: Read all registers via Port A
//         $display("\nTest 3: Read All Registers via Port A");
//         write_en = 0;
//         port_a_sel = 2'b00; #1; $display("Port A - R0: %h", port_a_data);
//         port_a_sel = 2'b01; #1; $display("Port A - R1: %h", port_a_data);
//         port_a_sel = 2'b10; #1; $display("Port A - R2: %h", port_a_data);
//         port_a_sel = 2'b11; #1; $display("Port A - R3: %h", port_a_data);
        
//         // Test 4: Read all registers via Port B
//         $display("\nTest 4: Read All Registers via Port B");
//         port_b_sel = 2'b00; #1; $display("Port B - R0: %h", port_b_data);
//         port_b_sel = 2'b01; #1; $display("Port B - R1: %h", port_b_data);
//         port_b_sel = 2'b10; #1; $display("Port B - R2: %h", port_b_data);
//         port_b_sel = 2'b11; #1; $display("Port B - R3: %h", port_b_data);
        
//         // Test 5: Simultaneous dual-port read
//         $display("\nTest 5: Simultaneous Dual-Port Read");
//         port_a_sel = 2'b00; port_b_sel = 2'b01; #1;
//         $display("Read R0 and R1 simultaneously: Port_A=%h, Port_B=%h", port_a_data, port_b_data);
        
//         port_a_sel = 2'b10; port_b_sel = 2'b11; #1;
//         $display("Read R2 and R3 simultaneously: Port_A=%h, Port_B=%h", port_a_data, port_b_data);
        
//         port_a_sel = 2'b00; port_b_sel = 2'b11; #1;
//         $display("Read R0 and R3 simultaneously: Port_A=%h, Port_B=%h", port_a_data, port_b_data);
        
//         // Test 6: Write disabled (write_en = 0)
//         $display("\nTest 6: Write Disable Test");
//         write_en = 0;
//         write_sel = 2'b00;
//         input_data = 8'hFF;
//         #10;
//         port_a_sel = 2'b00; #1;
//         $display("Attempt write %h to R0 with write_en=0, R0 remains: %h %s", 
//                  8'hFF, port_a_data, (port_a_data === 8'hAA) ? "PASS" : "FAIL");
        
//         // Test 7: Overwrite register
//         $display("\nTest 7: Overwrite Test");
//         write_en = 1;
//         write_sel = 2'b00;
//         input_data = 8'h11;
//         #10;
//         port_a_sel = 2'b00; #1;
//         $display("Overwrite R0 with %h: %h %s", 8'h11, port_a_data,
//                  (port_a_data === 8'h11) ? "PASS" : "FAIL");
        
//         // Test 8: Write to one register while reading others
//         $display("\nTest 8: Write While Reading");
//         write_sel = 2'b10;
//         input_data = 8'h99;
//         port_a_sel = 2'b01;  // Reading R1
//         port_b_sel = 2'b11;  // Reading R3
//         #10;
//         $display("Writing to R2, Reading R1=%h, R3=%h (should be unaffected)", 
//                  port_a_data, port_b_data);
//         port_a_sel = 2'b10; #1;
//         $display("Now read R2: %h %s", port_a_data, (port_a_data === 8'h99) ? "PASS" : "FAIL");
        
//         // Test 9: Sequential writes
//         $display("\nTest 9: Sequential Writes to All Registers");
//         write_en = 1;
//         write_sel = 2'b00; input_data = 8'h10; #10;
//         write_sel = 2'b01; input_data = 8'h20; #10;
//         write_sel = 2'b10; input_data = 8'h30; #10;
//         write_sel = 2'b11; input_data = 8'h40; #10;
        
//         write_en = 0;
//         port_a_sel = 2'b00; #1; $display("R0: %h (expected 10) %s", port_a_data, (port_a_data === 8'h10) ? "PASS" : "FAIL");
//         port_a_sel = 2'b01; #1; $display("R1: %h (expected 20) %s", port_a_data, (port_a_data === 8'h20) ? "PASS" : "FAIL");
//         port_a_sel = 2'b10; #1; $display("R2: %h (expected 30) %s", port_a_data, (port_a_data === 8'h30) ? "PASS" : "FAIL");
//         port_a_sel = 2'b11; #1; $display("R3: %h (expected 40) %s", port_a_data, (port_a_data === 8'h40) ? "PASS" : "FAIL");
        
//         // Test 10: Reset while holding data - CORRECTED
//         $display("\nTest 10: Reset After Writing");
//         write_en = 1;
//         write_sel = 2'b00; input_data = 8'hEE; #10;
//         write_sel = 2'b01; input_data = 8'hEF; #10;
        
//         // CRITICAL FIX: Disable write_en BEFORE asserting reset
//         write_en = 0;
//         #5;  // Small delay to ensure write_en is low
        
//         reset = 1; #20; reset = 0; #10;
        
//         // Now check that all registers are reset to 0
//         port_a_sel = 2'b00; port_b_sel = 2'b01; #1;
//         $display("After reset: R0=%h, R1=%h %s", port_a_data, port_b_data,
//                  (port_a_data === 8'h00 && port_b_data === 8'h00) ? "PASS" : "FAIL");
//         port_a_sel = 2'b10; port_b_sel = 2'b11; #1;
//         $display("After reset: R2=%h, R3=%h %s", port_a_data, port_b_data,
//                  (port_a_data === 8'h00 && port_b_data === 8'h00) ? "PASS" : "FAIL");
        
//         // Test 11: Reset priority over write
//         $display("\nTest 11: Reset Priority Test");
//         write_en = 1;
//         write_sel = 2'b00;
//         input_data = 8'hAB;
//         reset = 1;  // Assert reset while trying to write
//         #10;
//         reset = 0;
//         write_en = 0;
//         #10;
//         port_a_sel = 2'b00; #1;
//         $display("Reset while writing: R0=%h (expected 00) %s", port_a_data,
//                  (port_a_data === 8'h00) ? "PASS" : "FAIL");
        
//         $display("\n===== Test Complete =====");
//         #50;
//         $finish;
//     end
    
//     // Monitor
//     initial begin
//         $monitor("Time=%0t | clk=%b rst=%b we=%b | wsel=%b data_in=%h | pa_sel=%b pa_data=%h | pb_sel=%b pb_data=%h",
//                  $time, clk, reset, write_en, write_sel, input_data, 
//                  port_a_sel, port_a_data, port_b_sel, port_b_data);
//     end

// endmodule