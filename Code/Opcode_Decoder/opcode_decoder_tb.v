`timescale 1ns/1ps

module opcode_decoder_tb;

    // Testbench signals
    reg [7:0] A;
    wire [26:0] Y;
    
    // Instruction name storage for display
    reg [127:0] instr_name;
    
    // Instantiate the opcode decoder
    opcode_decoder uut (
        .A(A),
        .Y(Y)
    );
    
    // Function to get instruction name based on active Y output
    function [127:0] get_instr_name;
        input [26:0] y_val;
        begin
            case(1'b1)
                y_val[0]:  get_instr_name = "NOOP";
                y_val[1]:  get_instr_name = "INPUTC";
                y_val[2]:  get_instr_name = "INPUTCF";
                y_val[3]:  get_instr_name = "INPUTD";
                y_val[4]:  get_instr_name = "INPUTDF";
                y_val[5]:  get_instr_name = "MOVE";
                y_val[6]:  get_instr_name = "LOADI/LOADP";
                y_val[7]:  get_instr_name = "ADD";
                y_val[8]:  get_instr_name = "ADDI";
                y_val[9]:  get_instr_name = "SUB";
                y_val[10]: get_instr_name = "SUBI";
                y_val[11]: get_instr_name = "LOAD";
                y_val[12]: get_instr_name = "LOADF";
                y_val[13]: get_instr_name = "STORE";
                y_val[14]: get_instr_name = "STOREF";
                y_val[15]: get_instr_name = "SHIFTL";
                y_val[16]: get_instr_name = "SHIFTR";
                y_val[17]: get_instr_name = "CMP";
                y_val[18]: get_instr_name = "JUMP";
                y_val[19]: get_instr_name = "BRE/BRZ";
                y_val[20]: get_instr_name = "BRNE/BRNZ";
                y_val[21]: get_instr_name = "BRG";
                y_val[22]: get_instr_name = "BRGE";
                default:   get_instr_name = "UNKNOWN";
            endcase
        end
    endfunction
    
    // Function to compute expected Y output
    function [26:0] compute_expected_y;
        input [7:0] opcode;
        reg [3:0] upper_bits;
        reg [3:0] lower_bits;
        reg [26:0] result;
        begin
            upper_bits = opcode[7:4];  // Used for instruction decode
            lower_bits = opcode[3:0];  // Passed through to Y[26:23]
            result = 27'b0;
            
            // Set Y[26:23] = A[3:0] (lower 4 bits passthrough)
            result[23] = opcode[3];
				result[24] = opcode[2];
				result[25] = opcode[1];
				result[26] = opcode[0];
            
            // Decode based on upper 4 bits
            case(upper_bits)
                4'b0000: result[0] = 1'b1;   // NOOP
                4'b0001: begin  // INPUTC/CF/D/DF based on A[1:0]
                    case(opcode[1:0])
                        2'b00: result[1] = 1'b1;   // INPUTC
                        2'b01: result[2] = 1'b1;   // INPUTCF
                        2'b10: result[3] = 1'b1;   // INPUTD
                        2'b11: result[4] = 1'b1;   // INPUTDF
                    endcase
                end
                4'b0010: result[5] = 1'b1;   // MOVE
                4'b0011: result[6] = 1'b1;   // LOADI/LOADP
                4'b0100: result[7] = 1'b1;   // ADD
                4'b0101: result[8] = 1'b1;   // ADDI
                4'b0110: result[9] = 1'b1;   // SUB
                4'b0111: result[10] = 1'b1;  // SUBI
                4'b1000: result[11] = 1'b1;  // LOAD
                4'b1001: result[12] = 1'b1;  // LOADF
                4'b1010: result[13] = 1'b1;  // STORE
                4'b1011: result[14] = 1'b1;  // STOREF
                4'b1100: begin  // SHIFTL/SHIFTR based on A[0]
                    case(opcode[0])
                        1'b0: result[15] = 1'b1;  // SHIFTL
                        1'b1: result[16] = 1'b1;  // SHIFTR
                    endcase
                end
                4'b1101: result[17] = 1'b1;  // CMP
                4'b1110: result[18] = 1'b1;  // JUMP
                4'b1111: begin  // Branch instructions based on A[1:0]
                    case(opcode[1:0])
                        2'b00: result[19] = 1'b1;  // BRE/BRZ
                        2'b01: result[20] = 1'b1;  // BRNE/BRNZ
                        2'b10: result[21] = 1'b1;  // BRG
                        2'b11: result[22] = 1'b1;  // BRGE
                    endcase
                end
            endcase
            
            compute_expected_y = result;
        end
    endfunction
    
    // Task to test an opcode
    task test_opcode;
        input [7:0] opcode;
        input [127:0] expected_name;
        reg [26:0] expected_y;
        integer errors;
        begin
            A = opcode;
            #10;
            instr_name = get_instr_name(Y);
            expected_y = compute_expected_y(opcode);
            errors = 0;
            
            $display("Opcode: 0x%02h (0b%08b)", opcode, opcode);
            $display("  Actual   Y: 0b%027b -> %s", Y, instr_name);
            $display("  Expected Y: 0b%027b", expected_y);
            
            // Verify Y matches expected
            if (Y !== expected_y) begin
                $display("  ERROR: Output mismatch!");
                errors = errors + 1;
            end
            
            
            if (errors == 0) begin
                $display("  PASS");
            end
            $display("");
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("=== Opcode Decoder Testbench ===\n");
        $display("Architecture: A[7:4] -> instruction decode, A[3:0] -> Y[26:23] passthrough\n");
        
        // Test the example you provided
        $display("--- Testing Your Example ---");
        test_opcode(8'b0010_1011, "MOVE");
        
        $display("--- Testing Upper bits 0000 (NOOP) ---");
        test_opcode(8'b0000_0000, "NOOP");
        test_opcode(8'b0000_1111, "NOOP");
        test_opcode(8'b0000_1010, "NOOP");
        
        $display("--- Testing Upper bits 0001 (INPUT group) with A[1:0] select ---");
        test_opcode(8'b0001_0000, "INPUTC");
        test_opcode(8'b0001_0001, "INPUTCF");
        test_opcode(8'b0001_0010, "INPUTD");
        test_opcode(8'b0001_0011, "INPUTDF");
        test_opcode(8'b0001_1100, "INPUTC");    // Different lower bits
        test_opcode(8'b0001_1101, "INPUTCF");
        
        $display("--- Testing Upper bits 0010-1011 (Single decode) ---");
        test_opcode(8'b0010_0000, "MOVE");
        test_opcode(8'b0010_0101, "MOVE");      // Different lower bits
        test_opcode(8'b0011_0000, "LOADI/LOADP");
        test_opcode(8'b0011_1111, "LOADI/LOADP");
        test_opcode(8'b0100_0000, "ADD");
        test_opcode(8'b0101_0000, "ADDI");
        test_opcode(8'b0110_0000, "SUB");
        test_opcode(8'b0111_0000, "SUBI");
        test_opcode(8'b1000_0000, "LOAD");
        test_opcode(8'b1001_0000, "LOADF");
        test_opcode(8'b1010_0000, "STORE");
        test_opcode(8'b1011_0000, "STOREF");
        
        $display("--- Testing Upper bits 1100 (SHIFT group) with A[0] select ---");
        test_opcode(8'b1100_0000, "SHIFTL");
        test_opcode(8'b1100_0001, "SHIFTR");
        test_opcode(8'b1100_0010, "SHIFTL");
        test_opcode(8'b1100_0011, "SHIFTR");
        test_opcode(8'b1100_1110, "SHIFTL");
        test_opcode(8'b1100_1111, "SHIFTR");
        
        $display("--- Testing Upper bits 1101-1110 (Single decode) ---");
        test_opcode(8'b1101_0000, "CMP");
        test_opcode(8'b1101_0111, "CMP");
        test_opcode(8'b1110_0000, "JUMP");
        test_opcode(8'b1110_1010, "JUMP");
        
        $display("--- Testing Upper bits 1111 (Branch group) with A[1:0] select ---");
        test_opcode(8'b1111_0000, "BRE/BRZ");
        test_opcode(8'b1111_0001, "BRNE/BRNZ");
        test_opcode(8'b1111_0010, "BRG");
        test_opcode(8'b1111_0011, "BRGE");
        test_opcode(8'b1111_0100, "BRE/BRZ");   // Different A[3:2]
        test_opcode(8'b1111_0101, "BRNE/BRNZ");
        test_opcode(8'b1111_1110, "BRG");
        test_opcode(8'b1111_1111, "BRGE");
        
        $display("=== All Tests Complete ===");
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t A=0x%02h Y=0b%027b", $time, A, Y);
    end

endmodule