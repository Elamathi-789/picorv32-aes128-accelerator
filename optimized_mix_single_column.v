`timescale 1ns / 1ps

module optimized_mix_single_column(
    input  [31:0] column_in,
    output [31:0] column_out
);

    wire [7:0] a0;
    wire [7:0] a1;
    wire [7:0] a2;
    wire [7:0] a3;

    wire [7:0] x0;
    wire [7:0] x1;
    wire [7:0] x2;
    wire [7:0] x3;

    wire [7:0] y0;
    wire [7:0] y1;
    wire [7:0] y2;
    wire [7:0] y3;

    wire [7:0] b0;
    wire [7:0] b1;
    wire [7:0] b2;
    wire [7:0] b3;

    /*
     * Split the 32-bit column into four AES bytes.
     */

    assign a0 = column_in[31:24];
    assign a1 = column_in[23:16];
    assign a2 = column_in[15:8];
    assign a3 = column_in[7:0];

    /*
     * Multiplication by 2 in GF(2^8).
     * These results are reused to reduce repeated logic.
     */

    gf_mult2 mult2_a0 (
        .d_in(a0),
        .d_out(x0)
    );

    gf_mult2 mult2_a1 (
        .d_in(a1),
        .d_out(x1)
    );

    gf_mult2 mult2_a2 (
        .d_in(a2),
        .d_out(x2)
    );

    gf_mult2 mult2_a3 (
        .d_in(a3),
        .d_out(x3)
    );

    /*
     * Multiplication by 3:
     *
     * 3 × a = (2 × a) XOR a
     */

    assign y0 = x0 ^ a0;
    assign y1 = x1 ^ a1;
    assign y2 = x2 ^ a2;
    assign y3 = x3 ^ a3;

    /*
     * Optimized MixColumns equations.
     */

    assign b0 = x0 ^ y1 ^ a2 ^ a3;
    assign b1 = a0 ^ x1 ^ y2 ^ a3;
    assign b2 = a0 ^ a1 ^ x2 ^ y3;
    assign b3 = y0 ^ a1 ^ a2 ^ x3;

    assign column_out = {
        b0,
        b1,
        b2,
        b3
    };

endmodule