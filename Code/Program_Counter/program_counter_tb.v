`timescale 1ns/1ps

// Testbench
module program_counter_tb;

    // Clock period
    parameter CLK_PERIOD = 10;
    
    // Testbench signals
    reg clk;
    reg [5:0] A0, A1;
    reg c2, c3;
    wire [5:0] Y;
    
    // Test tracking
    integer test_num;
    integer pass_count, fail_count;
    reg [5:0] expected_Y;
    reg [5:0] expected_B0, expected_B1, expected_B;
    reg [5:0] prev_Y;
    
    // Instantiate the program counter
    program_counter uut (
        .A0(A0),
        .A1(A1),
        .clk(clk),
        .c2(c2),
        .c3(c3),
        .Y(Y)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Task to calculate expected B values
    task calculate_expected_B;
        begin
            expected_B0 = A0 + 6'b000001;        // Y0 = A0 + 1
            expected_B1 = A0 + A1 + 6'b000001;   // Y1 = A0 + A1 + 1
            expected_B = (c2 == 1'b1) ? expected_B0 : expected_B1;
        end
    endtask
    
    // Task to run a test case
    task run_test;
        input [5:0] test_A0, test_A1;
        input test_c2, test_c3;
        input [5:0] expect_Y;
        input [255:0] description;
        begin
            test_num = test_num + 1;
            
            // Capture current Y before applying inputs
            prev_Y = Y;
            
            // Set inputs
            A0 = test_A0;
            A1 = test_A1;
            c2 = test_c2;
            c3 = test_c3;
            
            calculate_expected_B();
            expected_Y = expect_Y;
            
            // Wait for positive clock edge
            @(posedge clk);
            #2; // Small delay after clock edge to allow propagation
            
            $display("\n--- Test %0d: %s ---", test_num, description);
            $display("Inputs: A0=%0d, A1=%0d, c2=%b, c3=%b", A0, A1, c2, c3);
            $display("Calculated: B0=%0d, B1=%0d, B=%0d", expected_B0, expected_B1, expected_B);
            $display("Previous Y: %0d", prev_Y);
            $display("Current Y:  %0d (0b%06b)", Y, Y);
            $display("Expected Y: %0d (0b%06b)", expected_Y, expected_Y);
            
            if (Y === expected_Y) begin
                $display("✓ PASS");
                pass_count = pass_count + 1;
            end
            else begin
                $display("✗ FAIL - Mismatch!");
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    // Task to wait for N clock cycles
    task wait_clocks;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("========================================");
        $display("  Program Counter Testbench");
        $display("========================================");
        $display("Note: Y register starts in unknown state");
        
        // Initialize signals
        A0 = 6'd0;
        A1 = 6'd0;
        c2 = 0;
        c3 = 0;
        
        // Wait a few clocks for initialization
        wait_clocks(2);
        $display("\nInitial Y value: %0d (undefined/X)", Y);
        
        $display("\n*** Testing c3=1, c2=1 (Write B0 = A0+1) ***");
        run_test(6'd0, 6'd0, 1'b1, 1'b1, 6'd1, "A0=0 -> Y=1");
        run_test(6'd5, 6'd10, 1'b1, 1'b1, 6'd6, "A0=5 -> Y=6");
        run_test(6'd15, 6'd20, 1'b1, 1'b1, 6'd16, "A0=15 -> Y=16");
        run_test(6'd30, 6'd5, 1'b1, 1'b1, 6'd31, "A0=30 -> Y=31");
        run_test(6'd50, 6'd8, 1'b1, 1'b1, 6'd51, "A0=50 -> Y=51");
        
        $display("\n*** Testing c3=1, c2=0 (Write B1 = A0+A1+1) ***");
        run_test(6'd0, 6'd0, 1'b0, 1'b1, 6'd1, "A0=0, A1=0 -> Y=1");
        run_test(6'd5, 6'd10, 1'b0, 1'b1, 6'd16, "A0=5, A1=10 -> Y=16");
        run_test(6'd10, 6'd20, 1'b0, 1'b1, 6'd31, "A0=10, A1=20 -> Y=31");
        run_test(6'd8, 6'd7, 1'b0, 1'b1, 6'd16, "A0=8, A1=7 -> Y=16");
        run_test(6'd15, 6'd5, 1'b0, 1'b1, 6'd21, "A0=15, A1=5 -> Y=21");
        
        $display("\n*** Testing c3=0 (Write Disabled - Hold) ***");
        $display("Y should maintain its current value");
        prev_Y = Y;
        run_test(6'd10, 6'd5, 1'b1, 1'b0, prev_Y, "c3=0, c2=1: Y holds");
        run_test(6'd20, 6'd10, 1'b0, 1'b0, prev_Y, "c3=0, c2=0: Y holds");
        run_test(6'd50, 6'd15, 1'b1, 1'b0, prev_Y, "c3=0, c2=1: Y holds");
        
        $display("\n*** Testing Sequential PC Increment ***");
        $display("Simulating normal instruction fetch sequence");
        
        // Initialize PC to 0
        A0 = 6'd0;
        A1 = 6'd0;
        c2 = 1'b1;
        c3 = 1'b1;
        @(posedge clk);
        #2;
        $display("\nInitialize PC to 0 (actual: %0d)", Y);
        
        // Sequential increments: PC = PC + 1
        A0 = Y;
        run_test(Y, 6'd0, 1'b1, 1'b1, Y+1, "Sequential: PC = PC + 1");
        
        A0 = Y;
        run_test(Y, 6'd0, 1'b1, 1'b1, Y+1, "Sequential: PC = PC + 1");
        
        A0 = Y;
        run_test(Y, 6'd0, 1'b1, 1'b1, Y+1, "Sequential: PC = PC + 1");
        
        A0 = Y;
        run_test(Y, 6'd0, 1'b1, 1'b1, Y+1, "Sequential: PC = PC + 1");
        
        $display("\n*** Testing Branch/Jump (PC = PC + offset + 1) ***");
        $display("Current PC: %0d", Y);
        prev_Y = Y;
        A0 = Y;
        A1 = 6'd10;
        run_test(Y, 6'd10, 1'b0, 1'b1, prev_Y + 6'd10 + 6'd1, "Branch: PC = PC + 10 + 1");
        
        prev_Y = Y;
        A0 = Y;
        A1 = 6'd5;
        run_test(Y, 6'd5, 1'b0, 1'b1, prev_Y + 6'd5 + 6'd1, "Branch: PC = PC + 5 + 1");
        
        $display("\n*** Testing All Control Signal Combinations ***");
        A0 = 6'd12;
        A1 = 6'd8;
        run_test(6'd12, 6'd8, 1'b0, 1'b0, Y, "c2=0, c3=0: Hold current");
        prev_Y = Y;
        run_test(6'd12, 6'd8, 1'b0, 1'b1, 6'd21, "c2=0, c3=1: Write B1=21 (12+8+1)");
        run_test(6'd12, 6'd8, 1'b1, 1'b0, 6'd21, "c2=1, c3=0: Hold 21");
        run_test(6'd12, 6'd8, 1'b1, 1'b1, 6'd13, "c2=1, c3=1: Write B0=13 (12+1)");
        
        $display("\n*** Testing Edge Cases ***");
        
        // Test maximum values
        run_test(6'd63, 6'd0, 1'b1, 1'b1, 6'd0, "Max: 63+1 -> 0 (overflow)");
        run_test(6'd62, 6'd0, 1'b1, 1'b1, 6'd63, "Near max: 62+1 -> 63");
        run_test(6'd60, 6'd3, 1'b0, 1'b1, 6'd0, "Overflow: 60+3+1 -> 0 (wraps)");
        
        // Test zero
        run_test(6'd0, 6'd0, 1'b1, 1'b1, 6'd1, "Zero: 0+1 -> 1");
        run_test(6'd0, 6'd0, 1'b0, 1'b1, 6'd1, "Zero with A1: 0+0+1 -> 1");
        
        $display("\n*** Testing Rapid Control Changes ***");
        A0 = 6'd20;
        A1 = 6'd5;
        c2 = 1'b1;
        c3 = 1'b1;
        @(posedge clk); #2;
        $display("Cycle 1: c2=1, c3=1 -> Y=%0d", Y);
        
        c2 = 1'b0;
        @(posedge clk); #2;
        $display("Cycle 2: c2=0, c3=1 -> Y=%0d", Y);
        
        c3 = 1'b0;
        @(posedge clk); #2;
        $display("Cycle 3: c2=0, c3=0 -> Y=%0d (should hold)", Y);
        
        // Summary
        wait_clocks(2);
        $display("\n========================================");
        $display("  Test Summary");
        $display("========================================");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("\n✓✓✓ All tests PASSED! ✓✓✓");
        end
        else begin
            $display("\n✗✗✗ Some tests FAILED! ✗✗✗");
        end
        
        $display("========================================\n");
        $finish;
    end
    
    // Monitor for continuous observation
    initial begin
        $monitor("Time=%0t | clk=%b | A0=%0d A1=%0d c2=%b c3=%b | B=%0d | Y=%0d", 
                 $time, clk, A0, A1, c2, c3, expected_B, Y);
    end
    
    // Waveform dump
    initial begin
        $dumpfile("program_counter_tb.vcd");
        $dumpvars(0, program_counter_tb);
    end

endmodule