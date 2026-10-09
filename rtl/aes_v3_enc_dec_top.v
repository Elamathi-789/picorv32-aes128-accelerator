`timescale 1ns / 1ps

module aes_v3_enc_dec_top(
    input clk,
    input rst,
    input start,

    // 0 = Encryption
    // 1 = Decryption
    input mode,

    input [127:0] data_in,
    input [127:0] key_in,

    output done,
    output [127:0] data_out
);

    // =========================================================
    // Encryption signals
    // =========================================================

    wire enc_done;
    wire [127:0] enc_ciphertext;


    // =========================================================
    // Decryption signals
    // =========================================================

    wire dec_done;
    wire [127:0] dec_plaintext;


    // =========================================================
    // AES ENCRYPTION
    // =========================================================

    aes_v3_top encryption_inst (
        .clk(clk),
        .rst(rst),
        .start(start && !mode),

        .plaintext(data_in),
        .key_in(key_in),

        .done(enc_done),
        .ciphertext(enc_ciphertext)
    );


    // =========================================================
    // AES DECRYPTION
    // =========================================================

    aes_v3_decrypt_top decryption_inst (
        .clk(clk),
        .rst(rst),
        .start(start && mode),

        .ciphertext(data_in),
        .key_in(key_in),

        .done(dec_done),
        .plaintext(dec_plaintext)
    );


    // =========================================================
    // OUTPUT SELECTION
    // =========================================================

    assign done = mode ? dec_done : enc_done;

    assign data_out = mode ? dec_plaintext : enc_ciphertext;


endmodule