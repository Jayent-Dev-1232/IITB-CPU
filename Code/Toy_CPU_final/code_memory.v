module code_memory (
    input wire [15:0] data_in,
    input wire [5:0] write_select,
    input wire [5:0] read_select,
    input wire select,
    output wire [15:0] data_out
);
    reg [15:0] memory_array [0:63];
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
        memory_array[i] = 16'b0;
    end

    always @(*) begin
        if (select) begin
            memory_array[write_select] = data_in;
        end
    end

    assign data_out = memory_array[read_select];
endmodule


// `timescale 1ns / 1ps

// module tb_code_memory;

//     // Inputs
//     reg [15:0] data_in;
//     reg [5:0] write_select;
//     reg [5:0] read_select;
//     reg select;
    
//     // Output
//     wire [15:0] data_out;
    
//     // Instantiate the Unit Under Test (UUT)
//     code_memory uut (
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
//         data_in = 16'h0000;
//         write_select = 6'b0;
//         read_select = 6'b0;
//         select = 0;
//         errors = 0;
        
//         // VCD dump for waveform viewing
//         $dumpfile("code_memory_tb.vcd");
//         $dumpvars(0, tb_code_memory);
        
//         $display("===== Code Memory Test =====\n");
        
//         // Test 1: Verify initial memory state (all zeros)
//         $display("Test 1: Initial Memory State");
//         select = 0;
//         for (i = 0; i < 64; i = i + 1) begin
//             read_select = i;
//             #10;
//             if (data_out !== 16'h0000) begin
//                 $display("ERROR: Memory[%0d] = %h, expected 0000", i, data_out);
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
//         write_select = 6'd0;
//         data_in = 16'hAAAA;
//         #10;
//         select = 0;
//         read_select = 6'd0;
//         #10;
//         $display("Write %h to addr %0d, Read back: %h %s", 
//                  16'hAAAA, 6'd0, data_out, (data_out === 16'hAAAA) ? "PASS" : "FAIL");
        
//         // Write to address 31
//         select = 1;
//         write_select = 6'd31;
//         data_in = 16'h5555;
//         #10;
//         select = 0;
//         read_select = 6'd31;
//         #10;
//         $display("Write %h to addr %0d, Read back: %h %s", 
//                  16'h5555, 6'd31, data_out, (data_out === 16'h5555) ? "PASS" : "FAIL");
        
//         // Write to address 63 (last location)
//         select = 1;
//         write_select = 6'd63;
//         data_in = 16'hFFFF;
//         #10;
//         select = 0;
//         read_select = 6'd63;
//         #10;
//         $display("Write %h to addr %0d, Read back: %h %s", 
//                  16'hFFFF, 6'd63, data_out, (data_out === 16'hFFFF) ? "PASS" : "FAIL");
        
//         // Test 3: Sequential write to all locations
//         $display("\nTest 3: Sequential Write to All Locations");
//         select = 1;
//         for (i = 0; i < 64; i = i + 1) begin
//             write_select = i;
//             data_in = 16'h1000 + i;  // Write unique pattern to each location
//             #10;
//         end
        
//         // Read back and verify
//         select = 0;
//         errors = 0;
//         for (i = 0; i < 64; i = i + 1) begin
//             read_select = i;
//             #10;
//             if (data_out !== (16'h1000 + i)) begin
//                 $display("ERROR: Memory[%0d] = %h, expected %h", i, data_out, 16'h1000 + i);
//                 errors = errors + 1;
//             end
//         end
//         if (errors == 0)
//             $display("PASS: All 64 locations written and verified correctly");
//         else
//             $display("FAIL: %0d locations have incorrect data", errors);
        
//         // Test 4: Overwrite existing data
//         $display("\nTest 4: Overwrite Test");
//         select = 1;
//         write_select = 6'd10;
//         data_in = 16'hDEAD;
//         #10;
//         select = 0;
//         read_select = 6'd10;
//         #10;
//         $display("First write to addr 10: %h", data_out);
        
//         select = 1;
//         write_select = 6'd10;
//         data_in = 16'hBEEF;
//         #10;
//         select = 0;
//         read_select = 6'd10;
//         #10;
//         $display("Overwrite addr 10: %h %s", 
//                  data_out, (data_out === 16'hBEEF) ? "PASS" : "FAIL");
        
//         // Test 5: Write disabled (select = 0)
//         $display("\nTest 5: Write Disable Test");
//         select = 0;
//         read_select = 6'd20;
//         #10;
//         $display("Current value at addr 20: %h", data_out);
        
//         select = 0;  // Write disabled
//         write_select = 6'd20;
//         data_in = 16'hCCCC;
//         #10;
//         read_select = 6'd20;
//         #10;
//         $display("After write attempt with select=0: %h %s", 
//                  data_out, (data_out !== 16'hCCCC) ? "PASS (no write)" : "FAIL (wrote despite select=0)");
        
//         // Test 6: Random access pattern
//         $display("\nTest 6: Random Access Pattern");
//         select = 1;
//         write_select = 6'd5;  data_in = 16'h1111; #10;
//         write_select = 6'd50; data_in = 16'h2222; #10;
//         write_select = 6'd15; data_in = 16'h3333; #10;
//         write_select = 6'd40; data_in = 16'h4444; #10;
        
//         select = 0;
//         read_select = 6'd5;  #10; $display("Read addr 5:  %h (expected 1111) %s", data_out, (data_out === 16'h1111) ? "PASS" : "FAIL");
//         read_select = 6'd50; #10; $display("Read addr 50: %h (expected 2222) %s", data_out, (data_out === 16'h2222) ? "PASS" : "FAIL");
//         read_select = 6'd15; #10; $display("Read addr 15: %h (expected 3333) %s", data_out, (data_out === 16'h3333) ? "PASS" : "FAIL");
//         read_select = 6'd40; #10; $display("Read addr 40: %h (expected 4444) %s", data_out, (data_out === 16'h4444) ? "PASS" : "FAIL");
        
//         // Test 7: Boundary conditions
//         $display("\nTest 7: Boundary Address Test");
//         select = 1;
//         write_select = 6'd0;  data_in = 16'hA0A0; #10;
//         write_select = 6'd63; data_in = 16'hB0B0; #10;
        
//         select = 0;
//         read_select = 6'd0;  #10; $display("Read addr 0 (min):  %h %s", data_out, (data_out === 16'hA0A0) ? "PASS" : "FAIL");
//         read_select = 6'd63; #10; $display("Read addr 63 (max): %h %s", data_out, (data_out === 16'hB0B0) ? "PASS" : "FAIL");
        
//         // Test 8: Simultaneous read and write to different addresses
//         $display("\nTest 8: Simultaneous Read/Write Different Addresses");
//         select = 1;
//         write_select = 6'd25;
//         data_in = 16'h9999;
//         read_select = 6'd30;  // Reading different address while writing
//         #10;
//         $display("Reading addr 30 while writing to addr 25: %h", data_out);
//         read_select = 6'd25;
//         #10;
//         $display("Verify write to addr 25: %h %s", data_out, (data_out === 16'h9999) ? "PASS" : "FAIL");
        
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