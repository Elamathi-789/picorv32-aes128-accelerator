`timescale 1ns / 1ps

module picosoc_aes (

    input  wire clk,
    input  wire resetn,

    // UART
    output wire ser_tx,
    input  wire ser_rx,

    // SPI flash
    output wire flash_csb,
    output wire flash_clk,

    output wire flash_io0_oe,
    output wire flash_io1_oe,
    output wire flash_io2_oe,
    output wire flash_io3_oe,

    output wire flash_io0_do,
    output wire flash_io1_do,
    output wire flash_io2_do,
    output wire flash_io3_do,

    input  wire flash_io0_di,
    input  wire flash_io1_di,
    input  wire flash_io2_di,
    input  wire flash_io3_di

);

    // ============================================================
    // PicoSoC MMIO interface
    // ============================================================

    wire        iomem_valid;
    wire        iomem_ready;
    wire [3:0]  iomem_wstrb;
    wire [31:0] iomem_addr;
    wire [31:0] iomem_wdata;
    wire [31:0] iomem_rdata;


    // ============================================================
    // AES interface
    // ============================================================

    wire         aes_start;
    wire         aes_mode;

    wire [127:0] aes_data_in;
    wire [127:0] aes_key_in;

    wire         aes_done;
    wire [127:0] aes_data_out;


    // ============================================================
    // Existing PicoSoC
    //
    // IMPORTANT:
    // We do NOT modify PicoRV32 or picosoc.v.
    // ============================================================

    picosoc soc (

        .clk(clk),
        .resetn(resetn),

        .iomem_valid(iomem_valid),
        .iomem_ready(iomem_ready),
        .iomem_wstrb(iomem_wstrb),
        .iomem_addr(iomem_addr),
        .iomem_wdata(iomem_wdata),
        .iomem_rdata(iomem_rdata),

        // No external interrupts used
        .irq_5(1'b0),
        .irq_6(1'b0),
        .irq_7(1'b0),

        // UART
        .ser_tx(ser_tx),
        .ser_rx(ser_rx),

        // SPI flash
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
    // AES MMIO peripheral
    // ============================================================

    aes_mmio #(
        .AES_BASE(32'h0300_0000)
    ) aes_mmio_inst (

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
    // Combined AES encryption/decryption accelerator
    // ============================================================

    aes_v3_enc_dec_top aes_core (

        .clk(clk),
        .rst(!resetn),

        .start(aes_start),
        .mode(aes_mode),

        .data_in(aes_data_in),
        .key_in(aes_key_in),

        .done(aes_done),
        .data_out(aes_data_out)
    );

endmodule