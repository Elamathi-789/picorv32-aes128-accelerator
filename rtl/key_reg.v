module key_reg(
	input clk , rst , load ,
	input [127:0] key_in ,
	output reg [127:0] key_out 
);

always @(posedge clk or posedge rst) begin
	if(rst) 
		key_out <= 128'd0 ;
	else if(load)
		key_out <= key_in ;
end

endmodule