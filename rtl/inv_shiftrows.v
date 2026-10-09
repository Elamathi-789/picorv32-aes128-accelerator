module inv_shiftrows(
    input  [127:0] state_in,
    output [127:0] state_out
);
assign state_out[127:120] = state_in[127:120]; // B0 <- B0
assign state_out[119:112] = state_in[23:16];  // B1 <- B13
assign state_out[111:104] = state_in[47:40];  // B2 <- B10
assign state_out[103:96]  = state_in[71:64];  // B3 <- B7
assign state_out[95:88]   = state_in[95:88];  // B4 <- B4
assign state_out[87:80]   = state_in[119:112]; // B5 <- B1
assign state_out[79:72]   = state_in[15:8];   // B6 <- B14
assign state_out[71:64]   = state_in[39:32];  // B7 <- B11
assign state_out[63:56]   = state_in[63:56];  // B8 <- B8
assign state_out[55:48]   = state_in[87:80];  // B9 <- B5
assign state_out[47:40]   = state_in[111:104]; // B10 <- B2
assign state_out[39:32]   = state_in[7:0];    // B11 <- B15
assign state_out[31:24]   = state_in[31:24];  // B12 <- B12
assign state_out[23:16]   = state_in[55:48];  // B13 <- B9
assign state_out[15:8]    = state_in[79:72];  // B14 <- B6
assign state_out[7:0]     = state_in[103:96]; // B15 <- B3
endmodule
