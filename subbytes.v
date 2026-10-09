module subbytes(
	input [127:0] state_in ,
	output [127:0] state_out
);

sbox b0(.byte_in(state_in[127:120]) , .byte_out(state_out[127:120])) ;
sbox b1(.byte_in(state_in[119:112]) , .byte_out(state_out[119:112])) ;
sbox b2(.byte_in(state_in[111:104]) , .byte_out(state_out[111:104])) ;
sbox b3(.byte_in(state_in[103:96]) , .byte_out(state_out[103:96])) ;
sbox b4(.byte_in(state_in[95:88]) , .byte_out(state_out[95:88])) ;
sbox b5(.byte_in(state_in[87:80]) , .byte_out(state_out[87:80])) ;  
sbox b6(.byte_in(state_in[79:72]) , .byte_out(state_out[79:72])) ;
sbox b7(.byte_in(state_in[71:64]) , .byte_out(state_out[71:64])) ;
sbox b8(.byte_in(state_in[63:56]) , .byte_out(state_out[63:56])) ;
sbox b9(.byte_in(state_in[55:48]) , .byte_out(state_out[55:48])) ;
sbox b10(.byte_in(state_in[47:40]) , .byte_out(state_out[47:40])) ;
sbox b11(.byte_in(state_in[39:32]) , .byte_out(state_out[39:32])) ;
sbox b12(.byte_in(state_in[31:24]) , .byte_out(state_out[31:24])) ;
sbox b13(.byte_in(state_in[23:16]) , .byte_out(state_out[23:16])) ;
sbox b14(.byte_in(state_in[15:8]) , .byte_out(state_out[15:8])) ;
sbox b15(.byte_in(state_in[7:0]) , .byte_out(state_out[7:0])) ;

endmodule