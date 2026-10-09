`timescale 1ns/1ps
module aes_v3_decrypt_top(
    input clk,
    input rst,
    input start,
    input [127:0] ciphertext,
    input [127:0] key_in,
    output reg done,
    output reg [127:0] plaintext
);

wire [127:0] k1,k2,k3,k4,k5,k6,k7,k8,k9,k10;
keyexpansion e1(key_in,4'd1,k1);
keyexpansion e2(k1,4'd2,k2);
keyexpansion e3(k2,4'd3,k3);
keyexpansion e4(k3,4'd4,k4);
keyexpansion e5(k4,4'd5,k5);
keyexpansion e6(k5,4'd6,k6);
keyexpansion e7(k6,4'd7,k7);
keyexpansion e8(k7,4'd8,k8);
keyexpansion e9(k8,4'd9,k9);
keyexpansion e10(k9,4'd10,k10);

reg busy;
reg [3:0] round;
reg [127:0] state;

reg [127:0] round_key;
wire [127:0] round_result;
wire [127:0] final_result;

always @(*) begin
    case(round)
        4'd9:  round_key=k9;
        4'd8:  round_key=k8;
        4'd7:  round_key=k7;
        4'd6:  round_key=k6;
        4'd5:  round_key=k5;
        4'd4:  round_key=k4;
        4'd3:  round_key=k3;
        4'd2:  round_key=k2;
        4'd1:  round_key=k1;
        default: round_key=key_in; // round 0
    endcase
end

aes_v3_decrypt_round normal_round(
    .round_in(state),
    .round_key(round_key),
    .round_out(round_result)
);

aes_v3_decrypt_final_round final_round(
    .round_in(state),
    .round_key(key_in),
    .round_out(final_result)
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        busy     <= 1'b0;
        round    <= 4'd0;
        state    <= 128'd0;
        plaintext<= 128'd0;
        done     <= 1'b0;
    end else begin
        done <= 1'b0;

        if(!busy) begin
            if(start) begin
                // Initial inverse step: C XOR K10
                state <= ciphertext ^ k10;
                round <= 4'd9;
                busy  <= 1'b1;
            end
        end else begin
            if(round != 4'd0) begin
                state <= round_result;
                round <= round - 4'd1;
            end else begin
                state     <= final_result;
                plaintext <= final_result;
                done      <= 1'b1;
                busy      <= 1'b0;
            end
        end
    end
end
endmodule
