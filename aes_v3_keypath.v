`timescale 1ns / 1ps

module aes_v3_keypath(
    input clk,
    input rst,
    input key_load,

    input [3:0] round,
    input [127:0] key_in,

    output [127:0] round_key
);

    wire [127:0] current_key;
    wire [127:0] next_key;

    /*
     * Stores the current round key.
     */
    key_reg key_reg_inst (
        .clk(clk),
        .rst(rst),
        .load(key_load),
        .key_in((round == 4'd0) ? key_in : next_key), 
        .key_out(current_key)
    );

    /*
     * Generates the next AES-128 round key.
     */
    keyexpansion keyexpansion_inst (
        .current_key(current_key),
        .round(round),
        .next_key(next_key)
    );

    /*
     * Round 0 uses the original input key.
     * Rounds 1 to 10 use the expanded key.
     */
    assign round_key = (round == 4'd0) ? key_in : next_key;

endmodule