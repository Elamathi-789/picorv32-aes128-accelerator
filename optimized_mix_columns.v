`timescale 1ns / 1ps

module optimized_mix_columns(
    input  [127:0] state_in,
    output [127:0] state_out
);

    wire [31:0] column0_in;
    wire [31:0] column1_in;
    wire [31:0] column2_in;
    wire [31:0] column3_in;

    wire [31:0] column0_out;
    wire [31:0] column1_out;
    wire [31:0] column2_out;
    wire [31:0] column3_out;

    /*
     * AES state is divided into four 32-bit columns.
     */

    assign column0_in = state_in[127:96];
    assign column1_in = state_in[95:64];
    assign column2_in = state_in[63:32];
    assign column3_in = state_in[31:0];

    /*
     * Each column is processed independently.
     * The optimized implementation reuses intermediate
     * GF(2^8) multiplication results.
     */

    optimized_mix_single_column mix_column0 (
        .column_in(column0_in),
        .column_out(column0_out)
    );

    optimized_mix_single_column mix_column1 (
        .column_in(column1_in),
        .column_out(column1_out)
    );

    optimized_mix_single_column mix_column2 (
        .column_in(column2_in),
        .column_out(column2_out)
    );

    optimized_mix_single_column mix_column3 (
        .column_in(column3_in),
        .column_out(column3_out)
    );

    assign state_out = {
        column0_out,
        column1_out,
        column2_out,
        column3_out
    };

endmodule