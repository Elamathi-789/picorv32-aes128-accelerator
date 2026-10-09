`timescale 1ns / 1ps

module aes_v3_datapath(
    input clk,
    input rst,
    input state_load,
    input final_sel,

    input [3:0] round,
    input [127:0] plaintext,
    input [127:0] round_key,

    output [127:0] ciphertext
);

    wire [127:0] state_out;
    wire [127:0] state_in;

    wire [127:0] round_result;
    wire [127:0] final_result;

    /*
     * AES normal round:
     * SubBytes → ShiftRows → Optimized MixColumns → AddRoundKey
     */
    aes_v3_round round_inst (
        .round_in(state_out),
        .round_key(round_key),
        .round_out(round_result)
    );

    /*
     * AES final round:
     * SubBytes → ShiftRows → AddRoundKey
     */
    aes_v3_final_round final_round_inst (
        .round_in(state_out),
        .round_key(round_key),
        .round_out(final_result)
    );

    /*
     * Initial AddRoundKey:
     * plaintext XOR original key
     */
    assign state_in =
        (round == 4'd0) ? (plaintext ^ round_key) :
        final_sel ? final_result :
        round_result;

    /*
     * Stores the AES state between rounds.
     */
    state_reg state_reg_inst (
        .clk(clk),
        .rst(rst),
        .load(state_load),
        .state_in(state_in),
        .state_out(state_out)
    );

    assign ciphertext = state_out;

endmodule