// rotate the bytes by 1 towards left
module rotword(
	input [31:0] word_in ,
	output [31:0] word_out
);

assign word_out[31:24] = word_in[23:16] ;
assign word_out[23:16] = word_in[15:8] ;
assign word_out[15:8] = word_in[7:0] ;
assign word_out[7:0] = word_in[31:24] ;

endmodule