module inv_mix_columns(
    input [127:0] state_in,
    output [127:0] state_out
);
inv_mix_single_column c0(state_in[127:96],state_out[127:96]);
inv_mix_single_column c1(state_in[95:64], state_out[95:64]);
inv_mix_single_column c2(state_in[63:32], state_out[63:32]);
inv_mix_single_column c3(state_in[31:0],  state_out[31:0]);
endmodule
