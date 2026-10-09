`timescale 1ns / 1ps

module aes_v3_round(
    input  [127:0] round_in,
    input  [127:0] round_key,
    output [127:0] round_out
);

    wire [127:0] subbytes_out;
    wire [127:0] shiftrows_out;
    wire [127:0] mixcolumns_out;

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

    // 3. Optimized MixColumns
    optimized_mix_columns optimized_mix_columns_inst (
        .state_in(shiftrows_out),
        .state_out(mixcolumns_out)
    );

    // 4. AddRoundKey
    addroundkey addroundkey_inst (
        .state_in(mixcolumns_out),
        .round_key(round_key),
        .state_out(round_out)
    );

endmodule