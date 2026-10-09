`timescale 1ns / 1ps

module aes_v3_controller(
    input clk,
    input rst,
    input start,

    output reg state_load,
    output reg key_load,
    output reg final_sel,

    output reg [3:0] round,
    output reg done
);

    localparam IDLE  = 3'd0;
    localparam INIT  = 3'd1;
    localparam ROUND = 3'd2;
    localparam FINAL = 3'd3;
    localparam DONE  = 3'd4;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            round <= 4'd0;
        end
        else begin
            state <= next_state;

            if (state == IDLE && start)
                round <= 4'd0;

            else if (state == INIT)
                round <= 4'd1;

            else if (state == ROUND && round < 4'd9)
                round <= round + 4'd1;

            else if (state == ROUND && round == 4'd9)
                round <= 4'd10;
        end
    end

    always @(*) begin

        next_state = state;

        case (state)

            IDLE: begin
                if (start)
                    next_state = INIT;
            end

            INIT: begin
                next_state = ROUND;
            end

            ROUND: begin
                if (round == 4'd9)
                    next_state = FINAL;
                else
                    next_state = ROUND;
            end

            FINAL: begin
                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    always @(*) begin

        state_load = 1'b0;
        key_load   = 1'b0;
        final_sel  = 1'b0;
        done       = 1'b0;

        case (state)

            INIT: begin
                state_load = 1'b1;
                key_load   = 1'b1;
            end

            ROUND: begin
                state_load = 1'b1;
                key_load   = 1'b1;
            end

            FINAL: begin
                state_load = 1'b1;
                final_sel  = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end

            default: begin
                state_load = 1'b0;
                key_load   = 1'b0;
                final_sel  = 1'b0;
                done       = 1'b0;
            end

        endcase
    end

endmodule