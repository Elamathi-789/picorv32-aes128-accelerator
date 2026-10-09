`timescale 1ns / 1ps

module aes_mmio #(
    parameter AES_BASE = 32'h0300_0000
)(
    input  wire        clk,
    input  wire        resetn,

    // PicoSoC MMIO interface
    input  wire        iomem_valid,
    output wire        iomem_ready,
    input  wire [3:0]  iomem_wstrb,
    input  wire [31:0] iomem_addr,
    input  wire [31:0] iomem_wdata,
    output reg  [31:0] iomem_rdata,

    // AES interface
    output reg         aes_start,
    output reg         aes_mode,
    output reg [127:0] aes_data_in,
    output reg [127:0] aes_key_in,

    input  wire        aes_done,
    input  wire [127:0] aes_data_out
);

    // ------------------------------------------------------------
    // Register offsets
    // ------------------------------------------------------------

    localparam ADDR_CONTROL  = 8'h00;
    localparam ADDR_STATUS   = 8'h04;

    localparam ADDR_DATA0    = 8'h08;
    localparam ADDR_DATA1    = 8'h0C;
    localparam ADDR_DATA2    = 8'h10;
    localparam ADDR_DATA3    = 8'h14;

    localparam ADDR_KEY0     = 8'h18;
    localparam ADDR_KEY1     = 8'h1C;
    localparam ADDR_KEY2     = 8'h20;
    localparam ADDR_KEY3     = 8'h24;

    localparam ADDR_OUT0     = 8'h28;
    localparam ADDR_OUT1     = 8'h2C;
    localparam ADDR_OUT2     = 8'h30;
    localparam ADDR_OUT3     = 8'h34;


    // ------------------------------------------------------------
    // Address decode
    // ------------------------------------------------------------

    wire aes_selected;

    assign aes_selected =
        iomem_valid &&
        (iomem_addr[31:8] == AES_BASE[31:8]);


    // AES register accesses complete immediately.
    assign iomem_ready = aes_selected;


    wire write_enable;
    wire read_enable;

    assign write_enable = aes_selected &&
                          (|iomem_wstrb);

    assign read_enable  = aes_selected &&
                          (iomem_wstrb == 4'b0000);


    // ------------------------------------------------------------
    // DONE status
    // ------------------------------------------------------------

    reg done_status;


    // ------------------------------------------------------------
    // Sequential register logic
    // ------------------------------------------------------------

    always @(posedge clk) begin

        if (!resetn) begin

            aes_start   <= 1'b0;
            aes_mode    <= 1'b0;

            aes_data_in <= 128'b0;
            aes_key_in  <= 128'b0;

            done_status <= 1'b0;

        end
        else begin

            // START is a pulse.
            aes_start <= 1'b0;


            // AES completed.
            if (aes_done)
                done_status <= 1'b1;


            // ------------------------------------------------
            // MMIO writes
            // ------------------------------------------------

            if (write_enable) begin

                case (iomem_addr[7:0])

                    // CONTROL
                    ADDR_CONTROL: begin

                        if (iomem_wstrb[0]) begin

                            aes_mode <= iomem_wdata[1];

                            if (iomem_wdata[0]) begin
                                aes_start   <= 1'b1;
                                done_status <= 1'b0;
                            end

                        end

                    end


                    // DATA INPUT
                    ADDR_DATA0: begin
                        if (iomem_wstrb[0])
                            aes_data_in[31:0] <= iomem_wdata;
                    end

                    ADDR_DATA1: begin
                        if (iomem_wstrb[0])
                            aes_data_in[63:32] <= iomem_wdata;
                    end

                    ADDR_DATA2: begin
                        if (iomem_wstrb[0])
                            aes_data_in[95:64] <= iomem_wdata;
                    end

                    ADDR_DATA3: begin
                        if (iomem_wstrb[0])
                            aes_data_in[127:96] <= iomem_wdata;
                    end


                    // KEY
                    ADDR_KEY0: begin
                        if (iomem_wstrb[0])
                            aes_key_in[31:0] <= iomem_wdata;
                    end

                    ADDR_KEY1: begin
                        if (iomem_wstrb[0])
                            aes_key_in[63:32] <= iomem_wdata;
                    end

                    ADDR_KEY2: begin
                        if (iomem_wstrb[0])
                            aes_key_in[95:64] <= iomem_wdata;
                    end

                    ADDR_KEY3: begin
                        if (iomem_wstrb[0])
                            aes_key_in[127:96] <= iomem_wdata;
                    end

                    default: begin
                    end

                endcase

            end

        end

    end


    // ------------------------------------------------------------
    // MMIO READ DATA
    // ------------------------------------------------------------

    always @(*) begin

        iomem_rdata = 32'b0;

        if (read_enable) begin

            case (iomem_addr[7:0])

                ADDR_CONTROL:
                    iomem_rdata = {30'b0, aes_mode, 1'b0};

                ADDR_STATUS:
                    iomem_rdata = {31'b0, done_status};


                ADDR_DATA0:
                    iomem_rdata = aes_data_in[31:0];

                ADDR_DATA1:
                    iomem_rdata = aes_data_in[63:32];

                ADDR_DATA2:
                    iomem_rdata = aes_data_in[95:64];

                ADDR_DATA3:
                    iomem_rdata = aes_data_in[127:96];


                ADDR_KEY0:
                    iomem_rdata = aes_key_in[31:0];

                ADDR_KEY1:
                    iomem_rdata = aes_key_in[63:32];

                ADDR_KEY2:
                    iomem_rdata = aes_key_in[95:64];

                ADDR_KEY3:
                    iomem_rdata = aes_key_in[127:96];


                ADDR_OUT0:
                    iomem_rdata = aes_data_out[31:0];

                ADDR_OUT1:
                    iomem_rdata = aes_data_out[63:32];

                ADDR_OUT2:
                    iomem_rdata = aes_data_out[95:64];

                ADDR_OUT3:
                    iomem_rdata = aes_data_out[127:96];


                default:
                    iomem_rdata = 32'h0000_0000;

            endcase

        end

    end

endmodule