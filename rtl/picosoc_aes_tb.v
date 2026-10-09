`timescale 1ns / 1ps

module picosoc_aes_tb;

    // ============================================================
    // Clock / Reset
    // ============================================================

    reg clk;
    reg resetn;

    always #5 clk = ~clk;


    // ============================================================
    // Board-level signals
    // ============================================================

    wire ser_tx;
    reg  ser_rx;

    wire flash_csb;
    wire flash_clk;

    wire flash_io0_oe;
    wire flash_io1_oe;
    wire flash_io2_oe;
    wire flash_io3_oe;

    wire flash_io0_do;
    wire flash_io1_do;
    wire flash_io2_do;
    wire flash_io3_do;

    reg flash_io0_di;
    reg flash_io1_di;
    reg flash_io2_di;
    reg flash_io3_di;


    // ============================================================
    // Instantiate complete PicoSoC + AES system
    // ============================================================

    picosoc_aes dut (

        .clk(clk),
        .resetn(resetn),

        .ser_tx(ser_tx),
        .ser_rx(ser_rx),

        .flash_csb(flash_csb),
        .flash_clk(flash_clk),

        .flash_io0_oe(flash_io0_oe),
        .flash_io1_oe(flash_io1_oe),
        .flash_io2_oe(flash_io2_oe),
        .flash_io3_oe(flash_io3_oe),

        .flash_io0_do(flash_io0_do),
        .flash_io1_do(flash_io1_do),
        .flash_io2_do(flash_io2_do),
        .flash_io3_do(flash_io3_do),

        .flash_io0_di(flash_io0_di),
        .flash_io1_di(flash_io1_di),
        .flash_io2_di(flash_io2_di),
        .flash_io3_di(flash_io3_di)
    );


    // ============================================================
    // Test variables
    // ============================================================

    reg [31:0] read_data;

    integer errors;


    // ============================================================
    // MMIO WRITE TASK
    //
    // We force the internal PicoSoC MMIO signals to simulate
    // a CPU-generated MMIO transaction.
    // ============================================================

    task mmio_write;

        input [31:0] address;
        input [31:0] data;

        begin

            $display("");
            $display("MMIO WRITE");
            $display("Address = %h", address);
            $display("Data    = %h", data);

            force dut.iomem_valid = 1'b1;
            force dut.iomem_addr  = address;
            force dut.iomem_wdata = data;
            force dut.iomem_wstrb = 4'b1111;

            @(posedge clk);

            while (!dut.iomem_ready)
                @(posedge clk);

            @(posedge clk);

            release dut.iomem_valid;
            release dut.iomem_addr;
            release dut.iomem_wdata;
            release dut.iomem_wstrb;

        end

    endtask


    // ============================================================
    // MMIO READ TASK
    // ============================================================

    task mmio_read;

        input  [31:0] address;
        output [31:0] data;

        begin

            $display("");
            $display("MMIO READ");
            $display("Address = %h", address);

            force dut.iomem_valid = 1'b1;
            force dut.iomem_addr  = address;
            force dut.iomem_wdata = 32'b0;
            force dut.iomem_wstrb = 4'b0000;

            @(posedge clk);

            while (!dut.iomem_ready)
                @(posedge clk);

            #1;

            data = dut.iomem_rdata;

            $display("Data    = %h", data);

            @(posedge clk);

            release dut.iomem_valid;
            release dut.iomem_addr;
            release dut.iomem_wdata;
            release dut.iomem_wstrb;

        end

    endtask


    // ============================================================
    // Main test
    // ============================================================

    initial begin

        clk = 1'b0;

        resetn = 1'b0;

        ser_rx = 1'b1;

        flash_io0_di = 1'b0;
        flash_io1_di = 1'b0;
        flash_io2_di = 1'b0;
        flash_io3_di = 1'b0;

        errors = 0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #50;

        resetn = 1'b1;

        #50;


        $display("");
        $display("============================================");
        $display("      PICOSOC + AES MMIO INTEGRATION");
        $display("============================================");


        // ========================================================
        // Write plaintext
        // ========================================================

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


        // ========================================================
        // Write AES key
        // ========================================================

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


        // ========================================================
        // Start encryption
        //
        // CONTROL:
        // bit 0 = START
        // bit 1 = MODE
        //
        // 01 = encryption
        // ========================================================

        mmio_write(
            32'h0300_0000,
            32'h00000001
        );


        // ========================================================
        // Wait for AES DONE
        // ========================================================

        $display("");
        $display("Waiting for AES encryption...");

        begin : WAIT_ENCRYPTION

            forever begin

                mmio_read(
                    32'h0300_0004,
                    read_data
                );

                if (read_data[0] == 1'b1)
                    disable WAIT_ENCRYPTION;

            end

        end


        // ========================================================
        // Read result
        // ========================================================

        mmio_read(
            32'h0300_0028,
            read_data
        );

        if (read_data != 32'h70B4C55A) begin

            $display("ERROR: DATA_OUT_0 incorrect!");
            errors = errors + 1;

        end


        mmio_read(
            32'h0300_002C,
            read_data
        );

        if (read_data != 32'hD8CDB780) begin

            $display("ERROR: DATA_OUT_1 incorrect!");
            errors = errors + 1;

        end


        mmio_read(
            32'h0300_0030,
            read_data
        );

        if (read_data != 32'h6A7B0430) begin

            $display("ERROR: DATA_OUT_2 incorrect!");
            errors = errors + 1;

        end


        mmio_read(
            32'h0300_0034,
            read_data
        );

        if (read_data != 32'h69C4E0D8) begin

            $display("ERROR: DATA_OUT_3 incorrect!");
            errors = errors + 1;

        end


        // ========================================================
        // Final result
        // ========================================================

        $display("");
        $display("============================================");

        if (errors == 0) begin

            $display("PICOSOC + AES MMIO TEST : PASS");

        end
        else begin

            $display("PICOSOC + AES MMIO TEST : FAIL");
            $display("Number of errors = %0d", errors);

        end

        $display("============================================");


        #100;

        $finish;

    end

endmodule