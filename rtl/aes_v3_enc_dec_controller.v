`timescale 1ns / 1ps

module aes_v3_enc_dec_controller(
    input clk,
    input rst,
    input start,
    input mode,              // 0 = Encryption, 1 = Decryption

    output reg state_load,
    output reg final_sel,

    output reg [3:0] round,
    output reg done,
    output reg mode_reg
);

    // FSM states
    localparam IDLE  = 3'd0;
    localparam INIT  = 3'd1;
    localparam ROUND = 3'd2;
    localparam FINAL = 3'd3;
    localparam DONE  = 3'd4;

    reg [2:0] state;
    reg [2:0] next_state;

    /*
     * FSM state register
     */
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            round    <= 4'd0;
            mode_reg <= 1'b0;
        end
        else begin
            state <= next_state;

            /*
             * Store encryption/decryption mode
             * when a new AES operation starts.
             */
            if (state == IDLE && start)
                mode_reg <= mode;

            /*
             * Encryption:
             *
             * INIT  -> round 0
             * ROUND -> 1,2,...,9
             * FINAL -> 10
             */
            if (state == IDLE && start) begin

                if (mode == 1'b0)
                    round <= 4'd0;
                else
                    /*
                     * Decryption starts with
                     * ciphertext XOR K10.
                     */
                    round <= 4'd10;

            end

            /*
             * Encryption round progression
             */
            else if (state == INIT && mode_reg == 1'b0) begin
                round <= 4'd1;
            end

            else if (state == ROUND && mode_reg == 1'b0) begin

                if (round < 4'd9)
                    round <= round + 4'd1;
                else
                    round <= 4'd10;

            end

            /*
             * Decryption round progression
             *
             * K10 -> K9 -> ... -> K1 -> K0
             */
            else if (state == INIT && mode_reg == 1'b1) begin
                round <= 4'd9;
            end

            else if (state == ROUND && mode_reg == 1'b1) begin

                if (round > 4'd1)
                    round <= round - 4'd1;
                else
                    round <= 4'd0;

            end

        end
    end


    /*
     * Next-state logic
     */
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

                /*
                 * Encryption:
                 * round 9 is followed by final round 10.
                 */
                if (mode_reg == 1'b0) begin

                    if (round == 4'd9)
                        next_state = FINAL;
                    else
                        next_state = ROUND;

                end

                /*
                 * Decryption:
                 * round 1 is followed by final round 0.
                 */
                else begin

                    if (round == 4'd1)
                        next_state = FINAL;
                    else
                        next_state = ROUND;

                end

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


    /*
     * Control signal generation
     */
    always @(*) begin

        state_load = 1'b0;
        final_sel  = 1'b0;
        done       = 1'b0;

        case (state)

            /*
             * Initial AES operation
             *
             * Encryption:
             * plaintext XOR K0
             *
             * Decryption:
             * ciphertext XOR K10
             */
            INIT: begin

                state_load = 1'b1;

            end


            /*
             * Normal AES rounds
             */
            ROUND: begin

                state_load = 1'b1;

            end


            /*
             * Final round
             *
             * Encryption:
             * SubBytes
             * ShiftRows
             * AddRoundKey
             *
             * Decryption:
             * InvShiftRows
             * InvSubBytes
             * AddRoundKey
             */
            FINAL: begin

                state_load = 1'b1;
                final_sel  = 1'b1;

            end


            /*
             * Operation complete
             */
            DONE: begin

                done = 1'b1;

            end


            default: begin

                state_load = 1'b0;
                final_sel  = 1'b0;
                done       = 1'b0;

            end

        endcase

    end

endmodule