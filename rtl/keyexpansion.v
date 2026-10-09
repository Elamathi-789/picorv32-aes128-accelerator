module keyexpansion(
	input [127:0] current_key ,
	input [3:0] round ,
	output [127:0] next_key 
);

wire [31:0] current_word0 , current_word1 , current_word2 , current_word3 ;

wire [31:0] next_word0 , next_word1 , next_word2 , next_word3 ; 

wire [31:0] g_out ;

g_function g_f(.word_in(current_word3) , .round(round) , .g_out(g_out)) ;

assign next_word0 = current_word0 ^ g_out ;
assign next_word1 = current_word1 ^ next_word0 ;
assign next_word2 = current_word2 ^ next_word1 ;
assign next_word3 = current_word3 ^ next_word2 ;

assign {current_word0 , current_word1 , current_word2 , current_word3} = current_key ;

assign next_key = {next_word0 , next_word1 , next_word2 , next_word3} ;

endmodule