module data_memory (
    input wire [7:0] data_in,
    input wire [3:0] write_select,
    input wire [3:0] read_select,
    input wire select,
    output wire [7:0] data_out
);
    reg [7:0] memory_array [0:15];
    integer i;
    initial begin
        for (i = 0; i < 15; i = i + 1)
        memory_array[i] = 8'b0;
    end

    always @(*) begin
        if (select) begin
            memory_array[write_select] = data_in;
        end
    end

    assign data_out = memory_array[read_select];
endmodule


// `timescale 1ns / 1ps

// module tb_data_memory;

//     // Inputs
//     reg [7:0] data_in;
//     reg [3:0] write_select;
//     reg [3:0] read_select;
//     reg select;
    
//     // Output
//     wire [7:0] data_out;
    
//     // Instantiate the Unit Under Test (UUT)
//     data_memory uut (
//         .data_in(data_in),
//         .write_select(write_select),
//         .read_select(read_select),
//         .select(select),
//         .data_out(data_out)
//     );
    
//     // Test variables
//     integer i;
//     integer errors;
    
//     initial begin
//         // Initialize inputs
//         data_in = 8'h00;
//         write_select = 4'b0;
//         read_select = 4'b0;
//         select = 0;
//         errors = 0;
        
//         // VCD dump for waveform viewing
//         $dumpfile("data_memory_tb.vcd");
//         $dumpvars(0, tb_data_memory);
        
//         $display("===== Data Memory Test =====\n");
        
//         // Test 1: Verify initial memory state (all zeros)
//         $display("Test 1: Initial Memory State");
//         select = 0;
//         for (i = 0; i < 16; i = i + 1) begin
//             read_select = i;
//             #10;
//             if (data_out !== 8'h00) begin
//                 $display("ERROR: Memory[%0d] = %h, expected 00", i, data_out);
//                 errors = errors + 1;
//             end
//         end
//         if (errors == 0)
//             $display("PASS: All memory locations initialized to 0\n");
//         else
//             $display("FAIL: %0d memory locations not initialized correctly\n", errors);
        
//         // Test 2: Write to specific locations and read back
//         $display("Test 2: Write and Read Operations");
//         select = 1;
        
//         // Write to address 0
//         write_select = 4'd0;
//         data_in = 8'hAA;
//         #10;
//         select = 0;
//         read_select = 4'd0;
//         #10;
//         $display("Write %h to addr %0d, Read back: %h %s", 
//                  8'hAA, 4'd0, data_out, (data_out === 8'hAA) ? "PASS" : "FAIL");
        
//         // Write to address 7 (middle)
//         select = 1;
//         write_select = 4'd7;
//         data_in = 8'h55;
//         #10;
//         select = 0;
//         read_select = 4'd7;
//         #10;
//         $display("Write %h to addr %0d, Read back: %h %s", 
//                  8'h55, 4'd7, data_out, (data_out === 8'h55) ? "PASS" : "FAIL");
        
//         // Write to address 15 (last location)
//         select = 1;
//         write_select = 4'd15;
//         data_in = 8'hFF;
//         #10;
//         select = 0;
//         read_select = 4'd15;
//         #10;
//         $display("Write %h to addr %0d, Read back: %h %s", 
//                  8'hFF, 4'd15, data_out, (data_out === 8'hFF) ? "PASS" : "FAIL");
        
//         // Test 3: Sequential write to all locations
//         $display("\nTest 3: Sequential Write to All Locations");
//         select = 1;
//         for (i = 0; i < 16; i = i + 1) begin
//             write_select = i;
//             data_in = 8'h10 + i;  // Write unique pattern to each location
//             #10;
//         end
        
//         // Read back and verify
//         select = 0;
//         errors = 0;
//         for (i = 0; i < 16; i = i + 1) begin
//             read_select = i;
//             #10;
//             if (data_out !== (8'h10 + i)) begin
//                 $display("ERROR: Memory[%0d] = %h, expected %h", i, data_out, 8'h10 + i);
//                 errors = errors + 1;
//             end
//         end
//         if (errors == 0)
//             $display("PASS: All 16 locations written and verified correctly");
//         else
//             $display("FAIL: %0d locations have incorrect data", errors);
        
//         // Test 4: Overwrite existing data
//         $display("\nTest 4: Overwrite Test");
//         select = 1;
//         write_select = 4'd5;
//         data_in = 8'hDE;
//         #10;
//         select = 0;
//         read_select = 4'd5;
//         #10;
//         $display("First write to addr 5: %h", data_out);
        
//         select = 1;
//         write_select = 4'd5;
//         data_in = 8'hBE;
//         #10;
//         select = 0;
//         read_select = 4'd5;
//         #10;
//         $display("Overwrite addr 5: %h %s", 
//                  data_out, (data_out === 8'hBE) ? "PASS" : "FAIL");
        
//         // Test 5: Write disabled (select = 0)
//         $display("\nTest 5: Write Disable Test");
//         select = 0;
//         read_select = 4'd10;
//         #10;
//         $display("Current value at addr 10: %h", data_out);
        
//         select = 0;  // Write disabled
//         write_select = 4'd10;
//         data_in = 8'hCC;
//         #10;
//         read_select = 4'd10;
//         #10;
//         $display("After write attempt with select=0: %h %s", 
//                  data_out, (data_out !== 8'hCC) ? "PASS (no write)" : "FAIL (wrote despite select=0)");
        
//         // Test 6: Random access pattern
//         $display("\nTest 6: Random Access Pattern");
//         select = 1;
//         write_select = 4'd2;  data_in = 8'h11; #10;
//         write_select = 4'd8;  data_in = 8'h22; #10;
//         write_select = 4'd13; data_in = 8'h33; #10;
//         write_select = 4'd6;  data_in = 8'h44; #10;
        
//         select = 0;
//         read_select = 4'd2;  #10; $display("Read addr 2:  %h (expected 11) %s", data_out, (data_out === 8'h11) ? "PASS" : "FAIL");
//         read_select = 4'd8;  #10; $display("Read addr 8:  %h (expected 22) %s", data_out, (data_out === 8'h22) ? "PASS" : "FAIL");
//         read_select = 4'd13; #10; $display("Read addr 13: %h (expected 33) %s", data_out, (data_out === 8'h33) ? "PASS" : "FAIL");
//         read_select = 4'd6;  #10; $display("Read addr 6:  %h (expected 44) %s", data_out, (data_out === 8'h44) ? "PASS" : "FAIL");
        
//         // Test 7: Boundary conditions
//         $display("\nTest 7: Boundary Address Test");
//         select = 1;
//         write_select = 4'd0;  data_in = 8'hA0; #10;
//         write_select = 4'd15; data_in = 8'hB0; #10;
        
//         select = 0;
//         read_select = 4'd0;  #10; $display("Read addr 0 (min):  %h %s", data_out, (data_out === 8'hA0) ? "PASS" : "FAIL");
//         read_select = 4'd15; #10; $display("Read addr 15 (max): %h %s", data_out, (data_out === 8'hB0) ? "PASS" : "FAIL");
        
//         // Test 8: Test with various data patterns
//         $display("\nTest 8: Various Data Patterns");
//         select = 1;
        
//         write_select = 4'd0; data_in = 8'b00000000; #10;  // All zeros
//         write_select = 4'd1; data_in = 8'b11111111; #10;  // All ones
//         write_select = 4'd2; data_in = 8'b10101010; #10;  // Alternating 1
//         write_select = 4'd3; data_in = 8'b01010101; #10;  // Alternating 2
//         write_select = 4'd4; data_in = 8'b11110000; #10;  // Upper half
//         write_select = 4'd5; data_in = 8'b00001111; #10;  // Lower half
        
//         select = 0;
//         read_select = 4'd0; #10; $display("Pattern 00000000: %b %s", data_out, (data_out === 8'b00000000) ? "PASS" : "FAIL");
//         read_select = 4'd1; #10; $display("Pattern 11111111: %b %s", data_out, (data_out === 8'b11111111) ? "PASS" : "FAIL");
//         read_select = 4'd2; #10; $display("Pattern 10101010: %b %s", data_out, (data_out === 8'b10101010) ? "PASS" : "FAIL");
//         read_select = 4'd3; #10; $display("Pattern 01010101: %b %s", data_out, (data_out === 8'b01010101) ? "PASS" : "FAIL");
//         read_select = 4'd4; #10; $display("Pattern 11110000: %b %s", data_out, (data_out === 8'b11110000) ? "PASS" : "FAIL");
//         read_select = 4'd5; #10; $display("Pattern 00001111: %b %s", data_out, (data_out === 8'b00001111) ? "PASS" : "FAIL");
        
//         // Test 9: Simultaneous read and write to different addresses
//         $display("\nTest 9: Simultaneous Read/Write Different Addresses");
//         select = 1;
//         write_select = 4'd9;
//         data_in = 8'h99;
//         read_select = 4'd12;  // Reading different address while writing
//         #10;
//         $display("Reading addr 12 while writing to addr 9: %h", data_out);
//         read_select = 4'd9;
//         #10;
//         $display("Verify write to addr 9: %h %s", data_out, (data_out === 8'h99) ? "PASS" : "FAIL");
        
//         // Test 10: Rapid write-read cycles
//         $display("\nTest 10: Rapid Write-Read Cycles");
//         for (i = 0; i < 16; i = i + 1) begin
//             select = 1;
//             write_select = i;
//             data_in = 8'hF0 | i;
//             #5;
//             select = 0;
//             read_select = i;
//             #5;
//             if (data_out !== (8'hF0 | i)) begin
//                 $display("FAIL: Rapid cycle addr %0d = %h, expected %h", i, data_out, 8'hF0 | i);
//             end
//         end
//         $display("Rapid write-read cycles complete");
        
//         $display("\n===== Test Complete =====");
//         #20;
//         $finish;
//     end
    
//     // Monitor for debugging
//     initial begin
//         $monitor("Time=%0t | select=%b | write_sel=%0d | read_sel=%0d | data_in=%h | data_out=%h",
//                  $time, select, write_select, read_select, data_in, data_out);
//     end

// endmodule