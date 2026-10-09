module rcon(
	input [3:0] round ,
	output reg [31:0] Rcon 
);

localparam round1 = 4'b0001 ,
			round2 = 4'b0010 ,
			round3 = 4'b0011 ,
			round4 = 4'b0100 ,
			round5 = 4'b0101 ,
			round6 = 4'b0110 ,
			round7 = 4'b0111 ,
			round8 = 4'b1000 ,
			round9 = 4'b1001 ,
			round10 = 4'b1010 ;

always @(*) begin
	case(round) 
			round1 : Rcon = 32'h01000000 ;
			round2 : Rcon = 32'h02000000 ;
			round3 : Rcon = 32'h04000000 ; 
			round4 : Rcon = 32'h08000000 ;
			round5 : Rcon = 32'h10000000 ;
			round6 : Rcon = 32'h20000000 ;
			round7 : Rcon = 32'h40000000 ;
			round8 : Rcon = 32'h80000000 ;
			round9 : Rcon = 32'h1B000000 ;
			round10 : Rcon = 32'h36000000 ;
			default : Rcon = 32'h00000000 ;
	endcase
end

endmodule