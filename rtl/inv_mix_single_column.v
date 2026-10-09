module inv_mix_single_column(
    input  [31:0] column_in,
    output [31:0] column_out
);
function [7:0] xtime;
input [7:0] x;
begin xtime = {x[6:0],1'b0} ^ (8'h1B & {8{x[7]}}); end
endfunction
function [7:0] mul9;
input [7:0] x; reg [7:0] x2,x4,x8;
begin x2=xtime(x); x4=xtime(x2); x8=xtime(x4); mul9=x8^x; end
endfunction
function [7:0] mulb;
input [7:0] x; reg [7:0] x2,x4,x8;
begin x2=xtime(x); x4=xtime(x2); x8=xtime(x4); mulb=x8^x2^x; end
endfunction
function [7:0] muld;
input [7:0] x; reg [7:0] x2,x4,x8;
begin x2=xtime(x); x4=xtime(x2); x8=xtime(x4); muld=x8^x4^x; end
endfunction
function [7:0] mule;
input [7:0] x; reg [7:0] x2,x4,x8;
begin x2=xtime(x); x4=xtime(x2); x8=xtime(x4); mule=x8^x4^x2; end
endfunction

wire [7:0] a0=column_in[31:24];
wire [7:0] a1=column_in[23:16];
wire [7:0] a2=column_in[15:8];
wire [7:0] a3=column_in[7:0];

assign column_out[31:24] = mule(a0)^mulb(a1)^muld(a2)^mul9(a3);
assign column_out[23:16] = mul9(a0)^mule(a1)^mulb(a2)^muld(a3);
assign column_out[15:8]  = muld(a0)^mul9(a1)^mule(a2)^mulb(a3);
assign column_out[7:0]   = mulb(a0)^muld(a1)^mul9(a2)^mule(a3);
endmodule
