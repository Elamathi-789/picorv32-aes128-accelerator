module gf_mult2(
    input  [7:0] d_in,
    output [7:0] d_out
);

assign d_out = d_in[7] ?
               ((d_in << 1) ^ 8'h1B) :
               (d_in << 1);

endmodule