module subword(
	input [31:0] word_in ,
	output [31:0] word_out
);

sbox b0(.byte_in(word_in[31:24]) , .byte_out(word_out[31:24])) ;
sbox b1(.byte_in(word_in[23:16]) , .byte_out(word_out[23:16])) ;
sbox b2(.byte_in(word_in[15:8]) , .byte_out(word_out[15:8])) ;
sbox b3(.byte_in(word_in[7:0]) , .byte_out(word_out[7:0])) ;

endmodule