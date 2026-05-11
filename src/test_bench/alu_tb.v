`timescale 1ns/1ps
 
module alu_testbench;
 
    // DUT signals
    reg [7:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [1:0] INV;
    reg [3:0] CMD;
    wire [15:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;
 
    // Reference model signals
    wire [15:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;
 
    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;
 
     alu_design #(.b(8),.c(4)) m1(.clk(CLK),.rst(RST),.mode(MODE),.ce(CE),.cin(CIN),
        .opa(OPA),.opb(OPB),.inp_valid(INV), .cmd(CMD),
        .res(RES_dut), .oflow(OFLOW_dut),.cout(COUT_dut), .g(G_dut), .l(L_dut), .e(E_dut), .err(ERR_dut));
 
 
    // Reference model instantiation
    reference_module #(.N(8),.cmdn(4)) m2(
        .opa(OPA), .opb(OPB), .cin(CIN),
        .mode(MODE), .cmd(CMD),
        .res(RES_ref),.in_val(INV),
        .cout(COUT_ref), .oflow(OFLOW_ref),
        .g(G_ref), .e(E_ref), .l(L_ref),
        .err(ERR_ref)
    );
 
 
 
    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
 
    // Test stimulus
    initial begin
        // Initialize
        RST = 1; CE = 1'b1; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0;INV=2'b11;
 
        @(posedge CLK);
        RST = 0;  // Release reset
        @(posedge CLK);
        $display("\n=== INPUT_VALID=2'b11 ===");
        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();
 
        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();
 
        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();
 
        /*INV=2'b00;
        @(posedge CLK);
        $display("\n=== INPUT_VALID=2'b00 ===");
        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();
 
        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();
 
        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();*/
 
        // Summary
        INV=2'b01;
        @(posedge CLK);
        $display("\n=== INPUT_VALID=2'b01 ===");
        // Test Arithmetic Operations
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();
 
        // Test Logical Operations
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();
 
        $display("\n=== Testing MULTIPLICATION Operations (MODE=1) ===");
        MODE = 1;
        test_mult();
 
 
        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
 
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");
 
        #1000;
        $finish;
    end
 
    // Test arithmetic operations
    task test_arithmetic();
        begin
            // ADD
            apply_test(8'h0F, 8'h11, 4'b0000, "ADD");
            apply_test(8'hFF, 8'h01, 4'b0000, "ADD (carry)");
 
            // SUB
            apply_test(8'h20, 8'h10, 4'b0001, "SUB");
            apply_test(8'h10, 8'h20, 4'b0001, "SUB (overflow)");
 
            // ADD_CIN
            CIN = 1;
            apply_test(8'h10, 8'h20, 4'b0010, "ADD_CIN");
            CIN = 0;
            apply_test(8'h10, 8'h20, 4'b0010, "ADD_CIN");
 
            // ADD_CIN
            CIN = 1;
            apply_test(8'hF0, 8'h20, 4'b0010, "ADD_CIN(carry)");
            CIN = 0;
            apply_test(8'hF0, 8'h20, 4'b0010, "ADD_CIN(carry)");
 
            // SUB_CIN
            CIN = 1;
            apply_test(8'h10, 8'h20, 4'b0011, "SUB_CIN(overflow)");
            CIN = 0;
            apply_test(8'h10, 8'h20, 4'b0011, "SUB_CIN(overflow)");
 
            // SUB_CIN
            CIN = 1;
            apply_test(8'hF0, 8'h20, 4'b0011, "SUB_CIN");
            CIN = 0;
            apply_test(8'hF0, 8'h20, 4'b0011, "SUB_CIN");
 
            // INC_A, DEC_A
            apply_test(8'h00, 8'h00, 4'b0100, "INC_A");
            apply_test(8'hFF, 8'h00, 4'b0100, "INC_A");
 
            apply_test(8'h0F, 8'h00, 4'b0101, "DEC_A");
            apply_test(8'h00, 8'h00, 4'b0101, "DEC_A");
 
            // INC_A, DEC_A
            apply_test(8'h00, 8'h00, 4'b0110, "INC_B");
            apply_test(8'h00, 8'hFF, 4'b0110, "INC_B");
 
            apply_test(8'h00, 8'h00, 4'b0111, "DEC_B");
            apply_test(8'h00, 8'hFF, 4'b0111, "DEC_B");
 
            // CMP
            apply_test(8'h10, 8'h10, 4'b1000, "CMP (equal)");
            apply_test(8'h20, 8'h10, 4'b1000, "CMP (greater)");
            apply_test(8'h10, 8'h20, 4'b1000, "CMP (less)");
 
 
            apply_test(8'h5A, 8'h0C, 4'b1011, "sign add positive ");
            apply_test(8'h5A, 8'h5C, 4'b1011, "sign add positive (overflow)");
            apply_test(8'hAA, 8'h0C, 4'b1011, "sign add negative ");
            apply_test(8'hAA, 8'hAC, 4'b1011, "sign add negative (overflow)");
 
            apply_test(8'h5A, 8'hF4, 4'b1100, "sign sub positive ");
            apply_test(8'h5A, 8'hA4, 4'b1100, "sign sub positive (overflow)");
            apply_test(8'hAA, 8'hF4, 4'b1100, "sign sub negative ");
            apply_test(8'hAA, 8'h54, 4'b1100, "sign sub negative (overflow)");
 
            //ERROR
            apply_test(8'hAA, 8'hFB, 4'b1101, "ERROR");
            apply_test(8'hAA, 8'hFB, 4'b1110, "ERROR");
            apply_test(8'hAA, 8'hFB, 4'b1111, "ERROR");
        end
    endtask
 
 
 
    // Test logical operations
    task test_logical();
        begin
            apply_test(8'hF0, 8'h0F, 4'b0000, "AND");
            apply_test(8'hF0, 8'h0F, 4'b0001, "NAND");
            apply_test(8'hF0, 8'h0F, 4'b0010, "OR");
            apply_test(8'hF0, 8'h0F, 4'b0011, "NOR");
            apply_test(8'hAA, 8'h55, 4'b0100, "XOR");
            apply_test(8'hAA, 8'h55, 4'b0101, "XNOR");
            apply_test(8'hF0, 8'h00, 4'b0110, "NOT_A");
            apply_test(8'hF0, 8'h0A, 4'b0111, "NOT_B");
            // INC_A, DEC_A
            apply_test(8'h01, 8'h00, 4'b1000, "RS_A");
            apply_test(8'h80, 8'h00, 4'b1000, "RS_A");
            apply_test(8'h01, 8'h00, 4'b1001, "LS_A");
            apply_test(8'h80, 8'h00, 4'b1001, "LS_A");
 
            // INC_A, DEC_A
            apply_test(8'h00, 8'h01, 4'b1010, "RS_B");
            apply_test(8'h00, 8'h80, 4'b1010, "RS_B");
            apply_test(8'h00, 8'h01, 4'b1011, "LS_B");
            apply_test(8'h00, 8'h80, 4'b1011, "LS_B");
 
            // CMP
            apply_test(8'hAA, 8'h0B, 4'b1100, "ROL");
            apply_test(8'hAA, 8'hFB, 4'b1100, "ROL");
            apply_test(8'hAA, 8'h00, 4'b1100, "ROL");
            apply_test(8'hAA, 8'h00, 4'b1101, "ROR");
            apply_test(8'hAA, 8'h0B, 4'b1101, "ROR");
            apply_test(8'hAA, 8'hFB, 4'b1101, "ROR");
 
            //Error
            apply_test(8'hAA, 8'hFB, 4'b1110, "ERROR");
            apply_test(8'hAA, 8'hFB, 4'b1111, "ERROR");
 
        end
    endtask
 
 
 
task test_mult();
        begin
            apply_test_mul(8'hFF, 8'hFF, 4'b1001, "MULT-CMD9");
            apply_test_mul(8'hF0, 8'h0F, 4'b1001, "MULT-CMD9");
            apply_test_mul(8'h00, 8'h00, 4'b1010, "MULT-CMD10");
            apply_test_mul(8'hF0, 8'h0F, 4'b1010, "MULT-CMD10");
        end
    endtask
 
    task apply_test_mul(
        input [7:0] a, b,
        input [3:0] cmd,
        input [80*8:1] test_name
    );
        begin
            @(negedge CLK);
            OPA = a;
            OPB = b;
            CMD = cmd;
 
            @(posedge CLK);
            @(posedge CLK);
                    @(posedge CLK);
                    #1;
                    test_count = test_count + 1;
                    if (compare_outputs(COUT_dut, COUT_ref)) begin
                        $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name, a, b, cmd);
                        pass_count = pass_count + 1;
                        display_mismatch();
                    end else begin
                        $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name, a, b, cmd);
                        display_mismatch();
                        fail_count = fail_count + 1;
                    end
                    @(posedge CLK);
        end
    endtask
 
    // Apply test and check
    task apply_test(
        input [7:0] a, b,
        input [3:0] cmd,
        input [80*8:1] test_name
    );
        begin
            @(negedge CLK);
            OPA = a;
            OPB = b;
            CMD = cmd;
 
            @(posedge CLK);
            @(posedge CLK);
                test_count = test_count + 1;
                #1;
                if (compare_outputs(COUT_dut, COUT_ref)) begin
                    $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",test_name, a, b, cmd);
                    pass_count = pass_count + 1;
                    display_mismatch();
                end else begin
                    $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",
                             test_name, a, b, cmd);
                    display_mismatch();
                    fail_count = fail_count + 1;
                end
        end
    endtask
 
 
 
    // Compare DUT vs Reference
    function compare_outputs(COUT_dut, COUT_ref);
        begin
            compare_outputs = 1;
 
            // Compare RES (handle Z values)
            if (RES_dut !== RES_ref) begin
                if (!((RES_dut === 8'hxx) && (RES_ref === 8'hxx)))
                    compare_outputs = 0;
            end
 
            // Compare flags (handle Z values)
            if (!compare_bit(COUT_dut, COUT_ref)) compare_outputs = 0;
            if (!compare_bit(OFLOW_dut, OFLOW_ref)) compare_outputs = 0;
            if (!compare_bit(G_dut, G_ref)) compare_outputs = 0;
            if (!compare_bit(E_dut, E_ref)) compare_outputs = 0;
            if (!compare_bit(L_dut, L_ref)) compare_outputs = 0;
            if (!compare_bit(ERR_dut, ERR_ref)) compare_outputs = 0;
        end
    endfunction
 
    function compare_bit(input dut, ref);
        begin
            if (dut === ref)
                compare_bit = 1;
            else if ((dut === 1'bz) && (ref === 1'bz))
                compare_bit = 1;
            else
                compare_bit = 0;
        end
    endfunction
 
    // Display mismatch details
    task display_mismatch();
        begin
                $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b", RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
                $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask
 
 
    // Waveform dump
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, alu_testbench);
    end
 
endmodule
