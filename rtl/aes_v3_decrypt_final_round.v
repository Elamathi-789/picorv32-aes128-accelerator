module aes_v3_decrypt_final_round(
    input [127:0] round_in,
    input [127:0] round_key,
    output [127:0] round_out
);
wire [127:0] a,b;
inv_shiftrows isr(round_in,a);
inv_subbytes  isb(a,b);
assign round_out = b ^ round_key;
endmodule
