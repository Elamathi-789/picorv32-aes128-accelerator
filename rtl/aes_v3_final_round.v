`timescale 1ns / 1ps

module aes_v3_final_round(
    input  [127:0] round_in,
    input  [127:0] round_key,
    output [127:0] round_out
);

    wire [127:0] subbytes_out;
    wire [127:0] shiftrows_out;

    /*
     * Final AES round:
     * SubBytes → ShiftRows → AddRoundKey
     *
     * MixColumns is not used in the final round.
     */

    // 1. SubBytes
    subbytes subbytes_inst (
        .state_in(round_in),
        .state_out(subbytes_out)
    );

    // 2. ShiftRows
    shiftrows shiftrows_inst (
        .state_in(subbytes_out),
        .state_out(shiftrows_out)
    );

    // 3. AddRoundKey
    addroundkey addroundkey_inst (
        .state_in(shiftrows_out),
        .round_key(round_key),
        .state_out(round_out)
    );

endmodule