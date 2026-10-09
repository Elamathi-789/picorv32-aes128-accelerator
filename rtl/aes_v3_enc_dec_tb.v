`timescale 1ns / 1ps

module aes_v3_enc_dec_tb;

    reg clk;
    reg rst;
    reg start;
    reg mode;

    reg [127:0] data_in;
    reg [127:0] key_in;

    wire done;
    wire [127:0] data_out;

    // =========================================================
    // DUT
    // =========================================================

    aes_v3_enc_dec_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mode(mode),
        .data_in(data_in),
        .key_in(key_in),
        .done(done),
        .data_out(data_out)
    );

    // =========================================================
    // CLOCK
    // 10 ns clock period
    // =========================================================

    always #5 clk = ~clk;

    // =========================================================
    // TEST
    // =========================================================

    initial begin

        // Initial values
        clk     = 0;
        rst     = 1;
        start   = 0;
        mode    = 0;
        data_in = 128'b0;
        key_in  = 128'b0;

        // -----------------------------------------------------
        // RESET
        // -----------------------------------------------------

        #20;
        rst = 0;

        // -----------------------------------------------------
        // AES-128 KEY
        // -----------------------------------------------------

        key_in = 128'h000102030405060708090A0B0C0D0E0F;

        // =====================================================
        // TEST 1 : ENCRYPTION
        // =====================================================

        mode    = 0;

        data_in = 128'h00112233445566778899AABBCCDDEEFF;

        #10;
        start = 1;

        #10;
        start = 0;

        // Wait for encryption to complete
        wait(done == 1);

        #10;

        $display("--------------------------------------------");
        $display("AES-128 ENCRYPTION");
        $display("--------------------------------------------");
        $display("Plaintext  = %h", data_in);
        $display("Key        = %h", key_in);
        $display("Ciphertext = %h", data_out);

        if (data_out == 128'h69C4E0D86A7B0430D8CDB78070B4C55A)
            $display("ENCRYPTION PASS");
        else
            $display("ENCRYPTION FAIL");

        // =====================================================
        // TEST 2 : DECRYPTION
        // =====================================================

        mode    = 1;

        data_in = 128'h69C4E0D86A7B0430D8CDB78070B4C55A;

        #10;
        start = 1;

        #10;
        start = 0;

        // Wait for decryption to complete
        wait(done == 1);

        #10;

        $display("--------------------------------------------");
        $display("AES-128 DECRYPTION");
        $display("--------------------------------------------");
        $display("Ciphertext = %h", data_in);
        $display("Key        = %h", key_in);
        $display("Plaintext  = %h", data_out);

        if (data_out == 128'h00112233445566778899AABBCCDDEEFF)
            $display("DECRYPTION PASS");
        else
            $display("DECRYPTION FAIL");

        // =====================================================
        // FINISH
        // =====================================================

        #20;

        $display("--------------------------------------------");
        $display("AES ENCRYPTION + DECRYPTION TEST COMPLETE");
        $display("--------------------------------------------");

        $finish;

    end

endmodule