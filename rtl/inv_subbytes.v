module inv_subbytes(
    input  [127:0] state_in,
    output [127:0] state_out
);
genvar i;
generate
    for(i=0;i<16;i=i+1) begin : GEN
        inv_sbox u(
            .byte_in(state_in[127-i*8 -: 8]),
            .byte_out(state_out[127-i*8 -: 8])
        );
    end
endgenerate
endmodule
