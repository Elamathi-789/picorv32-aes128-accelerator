`timescale 1ns / 1ps

module aes_v3_tb;

    reg clk;
    reg rst;
    reg start;

    reg [127:0] plaintext;
    reg [127:0] key_in;

    wire done;
    wire [127:0] ciphertext;

    aes_v3_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .plaintext(plaintext),
        .key_in(key_in),

        .done(done),
        .ciphertext(ciphertext)
    );

    /*
     * Clock generation: 10 ns period
     */
    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        rst = 1'b1;
        start = 1'b0;

        plaintext = 128'h00112233445566778899AABBCCDDEEFF;
        key_in   = 128'h000102030405060708090A0B0C0D0E0F;

        /*
         * Apply reset
         */
        #20;
        rst = 1'b0;

        /*
         * Start AES encryption
         */
        #10;
        start = 1'b1;

        #10;
        start = 1'b0;

        /*
         * Wait until encryption is complete
         */
        wait(done == 1'b1);

        #1;

        $display("======================================");
        $display("AES VERSION 3 TEST");
        $display("Plaintext  = %h", plaintext);
        $display("Key        = %h", key_in);
        $display("Ciphertext = %h", ciphertext);
        $display("Expected   = 69C4E0D86A7B0430D8CDB78070B4C55A");
        $display("======================================");

        if (ciphertext == 128'h69C4E0D86A7B0430D8CDB78070B4C55A)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        #20;
        $finish;

    end

endmodule