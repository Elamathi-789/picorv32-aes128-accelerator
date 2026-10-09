module g_function(
	input [31:0] word_in ,
	input [3:0] round ,
	output [31:0] g_out
);

wire [31:0] rot_out ;
wire [31:0] sub_out ;
wire [31:0] rcon_out ;

rotword w1(.word_in(word_in) , .word_out(rot_out)) ;
subword s1(.word_in(rot_out) , .word_out(sub_out)) ;
rcon r1(.round(round) , .Rcon(rcon_out)) ;

assign g_out = sub_out ^ rcon_out ;
	
endmodule 