`timescale 1ns / 1ps

module aes_v3_top(
    input clk,
    input rst,
    input start,

    input [127:0] plaintext,
    input [127:0] key_in,

    output done,
    output [127:0] ciphertext
);

    wire state_load;
    wire key_load;
    wire final_sel;

    wire [3:0] round;

    wire [127:0] round_key;

    aes_v3_controller controller_inst (
        .clk(clk),
        .rst(rst),
        .start(start),

        .state_load(state_load),
        .key_load(key_load),
        .final_sel(final_sel),

        .round(round),
        .done(done)
    );

    aes_v3_keypath keypath_inst (
        .clk(clk),
        .rst(rst),

        .key_load(key_load),
        .round(round),
        .key_in(key_in),

        .round_key(round_key)
    );

    aes_v3_datapath datapath_inst (
        .clk(clk),
        .rst(rst),

        .state_load(state_load),
        .final_sel(final_sel),

        .round(round),
        .plaintext(plaintext),
        .round_key(round_key),

        .ciphertext(ciphertext)
    );

endmodule