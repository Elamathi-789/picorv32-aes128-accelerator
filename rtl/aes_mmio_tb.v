`timescale 1ns / 1ps

module aes_mmio_tb;

    // ============================================================
    // Clock and reset
    // ============================================================

    reg clk;
    reg resetn;

    always #5 clk = ~clk;


    // ============================================================
    // PicoSoC MMIO signals
    // ============================================================

    reg         iomem_valid;
    wire        iomem_ready;
    reg  [3:0]  iomem_wstrb;
    reg  [31:0] iomem_addr;
    reg  [31:0] iomem_wdata;
    wire [31:0] iomem_rdata;


    // ============================================================
    // AES signals
    // ============================================================

    wire         aes_start;
    wire         aes_mode;

    wire [127:0] aes_data_in;
    wire [127:0] aes_key_in;

    wire         aes_done;
    wire [127:0] aes_data_out;


    // ============================================================
    // Instantiate MMIO wrapper
    // ============================================================

    aes_mmio #(
        .AES_BASE(32'h0300_0000)
    ) uut_mmio (

        .clk(clk),
        .resetn(resetn),

        .iomem_valid(iomem_valid),
        .iomem_ready(iomem_ready),
        .iomem_wstrb(iomem_wstrb),
        .iomem_addr(iomem_addr),
        .iomem_wdata(iomem_wdata),
        .iomem_rdata(iomem_rdata),

        .aes_start(aes_start),
        .aes_mode(aes_mode),
        .aes_data_in(aes_data_in),
        .aes_key_in(aes_key_in),

        .aes_done(aes_done),
        .aes_data_out(aes_data_out)
    );


    // ============================================================
    // Instantiate combined AES
    // ============================================================

    aes_v3_enc_dec_top uut_aes (

        .clk(clk),
        .rst(!resetn),

        .start(aes_start),
        .mode(aes_mode),

        .data_in(aes_data_in),
        .key_in(aes_key_in),

        .done(aes_done),
        .data_out(aes_data_out)
    );


    // ============================================================
    // MMIO WRITE TASK
    // ============================================================

    task mmio_write;

        input [31:0] address;
        input [31:0] data;

        begin

            // Drive transaction on falling edge.
            // This gives the DUT a stable setup before
            // the next rising edge.
            @(negedge clk);

            iomem_valid = 1'b1;
            iomem_wstrb = 4'b1111;
            iomem_addr  = address;
            iomem_wdata = data;

            // DUT samples transaction here.
            @(posedge clk);

            // Keep transaction active for the complete
            // clock cycle, then release it.
            @(negedge clk);

            iomem_valid = 1'b0;
            iomem_wstrb = 4'b0000;
            iomem_addr  = 32'b0;
            iomem_wdata = 32'b0;

        end

    endtask


    // ============================================================
    // MMIO READ TASK
    // ============================================================

    task mmio_read;

        input  [31:0] address;
        output [31:0] data;

        begin

            // Drive transaction on falling edge.
            @(negedge clk);

            iomem_valid = 1'b1;
            iomem_wstrb = 4'b0000;
            iomem_addr  = address;
            iomem_wdata = 32'b0;

            // DUT sees the read transaction.
            @(posedge clk);

            // Capture returned data.
            data = iomem_rdata;

            // Release transaction on falling edge.
            @(negedge clk);

            iomem_valid = 1'b0;
            iomem_wstrb = 4'b0000;
            iomem_addr  = 32'b0;
            iomem_wdata = 32'b0;

        end

    endtask


    // ============================================================
    // Test variables
    // ============================================================

    reg [31:0] status;
    reg [127:0] result;


    // ============================================================
    // Test
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initial values
        // --------------------------------------------------------

        clk         = 1'b0;
        resetn      = 1'b0;

        iomem_valid = 1'b0;
        iomem_wstrb = 4'b0000;
        iomem_addr  = 32'b0;
        iomem_wdata = 32'b0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #30;

        resetn = 1'b1;

        #20;


        // ========================================================
        // AES-128 ENCRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("       AES-128 MMIO ENCRYPTION TEST");
        $display("============================================");


        // --------------------------------------------------------
        // Write plaintext
        //
        // 00112233445566778899AABBCCDDEEFF
        // --------------------------------------------------------

        mmio_write(
            32'h0300_0008,
            32'hCCDDEEFF
        );

        mmio_write(
            32'h0300_000C,
            32'h8899AABB
        );

        mmio_write(
            32'h0300_0010,
            32'h44556677
        );

        mmio_write(
            32'h0300_0014,
            32'h00112233
        );


        // --------------------------------------------------------
        // Write AES key
        //
        // 000102030405060708090A0B0C0D0E0F
        // --------------------------------------------------------

        mmio_write(
            32'h0300_0018,
            32'h0C0D0E0F
        );

        mmio_write(
            32'h0300_001C,
            32'h08090A0B
        );

        mmio_write(
            32'h0300_0020,
            32'h04050607
        );

        mmio_write(
            32'h0300_0024,
            32'h00010203
        );


        // --------------------------------------------------------
        // Start encryption
        //
        // bit 0 = START
        // bit 1 = MODE
        // MODE = 0 -> encryption
        // --------------------------------------------------------

        mmio_write(
            32'h0300_0000,
            32'h00000001
        );


        // --------------------------------------------------------
        // Wait for DONE
        // --------------------------------------------------------

        begin : WAIT_ENCRYPTION

            forever begin

                mmio_read(
                    32'h0300_0004,
                    status
                );

                if (status[0])
                    disable WAIT_ENCRYPTION;

            end

        end


        // --------------------------------------------------------
        // Read ciphertext
        // --------------------------------------------------------

        mmio_read(
            32'h0300_0028,
            result[31:0]
        );

        mmio_read(
            32'h0300_002C,
            result[63:32]
        );

        mmio_read(
            32'h0300_0030,
            result[95:64]
        );

        mmio_read(
            32'h0300_0034,
            result[127:96]
        );


        $display("");
        $display("Plaintext  = %h",
                 128'h00112233445566778899AABBCCDDEEFF);

        $display("Key        = %h",
                 128'h000102030405060708090A0B0C0D0E0F);

        $display("Ciphertext = %h",
                 result);


        if (result ==
            128'h69C4E0D86A7B0430D8CDB78070B4C55A) begin

            $display(">>> ENCRYPTION PASS <<<");

        end
        else begin

            $display(">>> ENCRYPTION FAIL <<<");

        end


        // ========================================================
        // AES-128 DECRYPTION
        // ========================================================

        $display("");
        $display("============================================");
        $display("       AES-128 MMIO DECRYPTION TEST");
        $display("============================================");


        // --------------------------------------------------------
        // Write ciphertext
        //
        // 69C4E0D86A7B0430D8CDB78070B4C55A
        // --------------------------------------------------------

        mmio_write(
            32'h0300_0008,
            32'h70B4C55A
        );

        mmio_write(
            32'h0300_000C,
            32'hD8CDB780
        );

        mmio_write(
            32'h0300_0010,
            32'h6A7B0430
        );

        mmio_write(
            32'h0300_0014,
            32'h69C4E0D8
        );


        // --------------------------------------------------------
        // Write AES key
        //
        // 000102030405060708090A0B0C0D0E0F
        // --------------------------------------------------------

        mmio_write(
            32'h0300_0018,
            32'h0C0D0E0F
        );

        mmio_write(
            32'h0300_001C,
            32'h08090A0B
        );

        mmio_write(
            32'h0300_0020,
            32'h04050607
        );

        mmio_write(
            32'h0300_0024,
            32'h00010203
        );


        // --------------------------------------------------------
        // Start DECRYPTION
        //
        // bit 0 = START = 1
        // bit 1 = MODE  = 1
        //
        // CONTROL = 2'b11 = 3
        // --------------------------------------------------------

        mmio_write(
            32'h0300_0000,
            32'h00000003
        );


        // --------------------------------------------------------
        // Wait for DONE
        // --------------------------------------------------------

        begin : WAIT_DECRYPTION

            forever begin

                mmio_read(
                    32'h0300_0004,
                    status
                );

                if (status[0])
                    disable WAIT_DECRYPTION;

            end

        end


        // --------------------------------------------------------
        // Read decrypted plaintext
        // --------------------------------------------------------

        mmio_read(
            32'h0300_0028,
            result[31:0]
        );

        mmio_read(
            32'h0300_002C,
            result[63:32]
        );

        mmio_read(
            32'h0300_0030,
            result[95:64]
        );

        mmio_read(
            32'h0300_0034,
            result[127:96]
        );


        $display("");
        $display("Ciphertext = %h",
                 128'h69C4E0D86A7B0430D8CDB78070C4C55A);

        $display("Key        = %h",
                 128'h000102030405060708090A0B0C0D0E0F);

        $display("Plaintext  = %h",
                 result);


        if (result ==
            128'h00112233445566778899AABBCCDDEEFF) begin

            $display(">>> DECRYPTION PASS <<<");

        end
        else begin

            $display(">>> DECRYPTION FAIL <<<");

        end


        // --------------------------------------------------------
        // Finish
        // --------------------------------------------------------

        #50;

        $display("");
        $display("============================================");
        $display("       AES MMIO TEST COMPLETE");
        $display("============================================");

        $finish;

    end

endmodule