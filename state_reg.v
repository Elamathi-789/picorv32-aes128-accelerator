//Stores the current 128-bit AES state
module state_reg(
	input clk , rst , load ,
	input [127:0] state_in ,
	output reg [127:0] state_out 
);

always @(posedge clk or posedge rst) begin
	if(rst) 
		state_out <= 128'd0 ;
	else if(load)
		state_out <= state_in ;
end

endmodule