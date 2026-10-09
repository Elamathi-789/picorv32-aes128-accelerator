`timescale 1ns/1ps
module aes_v3_decrypt_tb;
reg clk,rst,start;
reg [127:0] ciphertext,key_in;
wire done;
wire [127:0] plaintext;

aes_v3_decrypt_top dut(
    .clk(clk), .rst(rst), .start(start),
    .ciphertext(ciphertext), .key_in(key_in),
    .done(done), .plaintext(plaintext)
);

always #5 clk=~clk;

initial begin
    clk=0; rst=1; start=0;
    ciphertext=128'h69C4E0D86A7B0430D8CDB78070B4C55A;
    key_in=128'h000102030405060708090A0B0C0D0E0F;

    #20 rst=0;
    #10 start=1;
    #10 start=0;

    wait(done);
    #1;

    $display("======================================");
    $display("AES-128 DECRYPTION TEST");
    $display("Ciphertext = %h",ciphertext);
    $display("Key        = %h",key_in);
    $display("Plaintext  = %h",plaintext);
    $display("Expected   = 00112233445566778899AABBCCDDEEFF");
    $display("======================================");

    if(plaintext==128'h00112233445566778899AABBCCDDEEFF)
        $display("DECRYPTION TEST PASSED");
    else
        $display("DECRYPTION TEST FAILED");

    #20 $finish;
end
endmodule
