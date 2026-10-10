`timescale 1ns/1ps
// Full-firmware simulation: real PicoRV32 + real spimemio + behavioral SPI flash,
// plus an independent UART receiver (decodes ser_tx at BAUD) and clock/baud measurement.
// No force/release. RTL files are untouched.
module picosoc_firmware_tb;

    parameter integer BAUD = 115200;               // what the PC terminal will use
    localparam real   BIT_NS = 1.0e9 / BAUD;       // ideal bit time
    // Testbench clock below is 10 ns period = 100 MHz.

    reg clk = 1'b0;
    reg resetn = 1'b0;
    always #10 clk = ~clk;

    wire ser_tx;
    wire flash_csb, flash_clk;
    wire flash_io0_oe, flash_io1_oe, flash_io2_oe, flash_io3_oe;
    wire flash_io0_do, flash_io1_do, flash_io2_do, flash_io3_do;
    wire flash_io0, flash_io1, flash_io2, flash_io3;

    assign flash_io0 = flash_io0_oe ? flash_io0_do : 1'bz;
    assign flash_io1 = flash_io1_oe ? flash_io1_do : 1'bz;
    assign flash_io2 = flash_io2_oe ? flash_io2_do : 1'bz;
    assign flash_io3 = flash_io3_oe ? flash_io3_do : 1'bz;

    picosoc_aes dut (
        .clk(clk), .resetn(resetn),
        .ser_tx(ser_tx), .ser_rx(1'b1),
        .flash_csb(flash_csb), .flash_clk(flash_clk),
        .flash_io0_oe(flash_io0_oe), .flash_io1_oe(flash_io1_oe),
        .flash_io2_oe(flash_io2_oe), .flash_io3_oe(flash_io3_oe),
        .flash_io0_do(flash_io0_do), .flash_io1_do(flash_io1_do),
        .flash_io2_do(flash_io2_do), .flash_io3_do(flash_io3_do),
        .flash_io0_di(flash_io0),    .flash_io1_di(flash_io1),
        .flash_io2_di(flash_io2),    .flash_io3_di(flash_io3)
    );

    // Image loaded from +firmware=<file> (byte-per-entry hex with @00100000 origin)
    spiflash flash (
        .csb(flash_csb), .clk(flash_clk),
        .io0(flash_io0), .io1(flash_io1), .io2(flash_io2), .io3(flash_io3)
    );

    integer cycles = 0;
    integer fetches = 0;
    integer aes_writes = 0;
    integer aes_reads = 0;
    reg [31:0] result;
    reg result_seen = 1'b0;

    initial begin
        repeat (20) @(posedge clk);
        resetn = 1'b1;
    end

    // ---------------- CPU / AES bus evidence ----------------
    always @(posedge clk) if (resetn) begin
        if (dut.soc.mem_valid && dut.soc.mem_ready && dut.soc.mem_instr &&
            dut.soc.mem_addr >= 32'h00100000 && dut.soc.mem_addr < 32'h02000000) begin
            fetches = fetches + 1;
            if (fetches <= 2)
                $display("[%0t] FETCH  addr=%08h data=%08h", $time,
                         dut.soc.mem_addr, dut.soc.mem_rdata);
        end
        if (dut.iomem_valid && dut.iomem_ready &&
            dut.iomem_addr[31:8] == 24'h030000) begin
            if (|dut.iomem_wstrb) aes_writes = aes_writes + 1;
            else                  aes_reads  = aes_reads + 1;
        end
    end

    // Show the UART divider the firmware programs
    always @(posedge clk) if (resetn) begin
        if (dut.soc.mem_valid && dut.soc.mem_ready &&
            dut.soc.mem_addr == 32'h02000004 && |dut.soc.mem_wstrb)
            $display("[%0t] UART_DIV written = %0d", $time, dut.soc.mem_wdata);
    end

    // ---------------- independent UART receiver (8N1 @ BAUD) ----------------
    reg [7:0] uart_log [0:1023];
    integer   uart_n = 0;
    integer   framing_errors = 0;
    reg [7:0] rx_byte;
    integer   k;

    initial begin : uart_rx
        forever begin
            @(negedge ser_tx);
            if (resetn && ser_tx === 1'b0) begin
                #(BIT_NS * 1.5);                       // middle of data bit 0
                for (k = 0; k < 8; k = k + 1) begin
                    rx_byte[k] = ser_tx;
                    #(BIT_NS);
                end
                if (ser_tx !== 1'b1) framing_errors = framing_errors + 1;  // stop bit
                if (uart_n < 1024) begin
                    uart_log[uart_n] = rx_byte;
                    uart_n = uart_n + 1;
                end
            end
        end
    end

    // ---------------- measure real bit period and SPI clock ----------------
    real last_tx_t = 0.0, min_tx_ns = 1.0e12;
    real last_sck_t = 0.0, min_sck_ns = 1.0e12;

    always @(ser_tx) if (resetn && (ser_tx === 1'b0 || ser_tx === 1'b1)) begin
        if (last_tx_t > 0.0 && ($realtime - last_tx_t) < min_tx_ns)
            min_tx_ns = $realtime - last_tx_t;
        last_tx_t = $realtime;
    end

    always @(flash_clk) if (resetn && (flash_clk === 1'b0 || flash_clk === 1'b1)) begin
        if (last_sck_t > 0.0 && ($realtime - last_sck_t) < min_sck_ns)
            min_sck_ns = $realtime - last_sck_t;
        last_sck_t = $realtime;
    end

    // ---------------- helpers ----------------
    // 1 if the UART log contains the ASCII pattern (right-aligned in pat)
    function integer log_has;
        input [8*48-1:0] pat;
        integer plen, s, j, b;
        reg ok;
        begin
            plen = 0;
            for (b = 47; b >= 0; b = b - 1)
                if (pat[8*b +: 8] != 8'h00 && plen == 0) plen = b + 1;
            log_has = 0;
            for (s = 0; s + plen <= uart_n; s = s + 1) begin
                ok = 1;
                for (j = 0; j < plen; j = j + 1)
                    if (uart_log[s+j] !== pat[8*(plen-1-j) +: 8]) ok = 0;
                if (ok) log_has = 1;
            end
        end
    endfunction

    // ---------------- completion / timeout ----------------
    always @(posedge clk) if (resetn) begin
        cycles = cycles + 1;
        result = dut.soc.memory.mem[0];
        if (!result_seen && result[31:4] == 28'hA35E000 && result[3:0] != 4'h0)
            result_seen = 1'b1;
        if (cycles >= 6000000) begin
            $display("SIMULATION TIMEOUT. RAM[0]=%08h fetches=%0d aes_wr=%0d uart_chars=%0d",
                     result, fetches, aes_writes, uart_n);
            $finish;
        end
    end

    integer i, fails;
    real baud_err_pct, sck_mhz;
    initial begin
        wait (result_seen);
        repeat (30000) @(posedge clk);   // let the last UART characters finish shifting
        fails = 0;

        $display("----------------------------------------");
        $display("RAM[0] result code = %08h", result);
        $display("UART text received (decoded independently at %0d baud):", BAUD);
        for (i = 0; i < uart_n; i = i + 1) $write("%c", uart_log[i]);
        $display("----------------------------------------");

        baud_err_pct = (min_tx_ns - BIT_NS) / BIT_NS * 100.0;
        sck_mhz = 1000.0 / (2.0 * min_sck_ns);
        $display("Measured UART bit time = %0.1f ns (ideal %0.1f ns) -> %0.0f baud, error %0.3f %%",
                 min_tx_ns, BIT_NS, 1.0e9 / min_tx_ns, baud_err_pct);
        $display("Measured SPI flash SCK = %0.1f MHz (half-period %0.1f ns)", sck_mhz, min_sck_ns);
        $display("Cycles=%0d  flash fetches=%0d  AES writes=%0d  AES reads=%0d  UART chars=%0d",
                 cycles, fetches, aes_writes, aes_reads, uart_n);

        if (result === 32'hA35E0001) $display("CHECK firmware result code ........ PASS");
        else begin $display("CHECK firmware result code ........ FAIL"); fails = fails + 1; end

        if (log_has("Ciphertext = 69C4E0D86A7B0430D8CDB78070B4C55A"))
            $display("CHECK UART ciphertext line ...... PASS");
        else begin $display("CHECK UART ciphertext line ...... FAIL"); fails = fails + 1; end

        if (log_has("Decrypted  = 00112233445566778899AABBCCDDEEFF"))
            $display("CHECK UART decrypted line ....... PASS");
        else begin $display("CHECK UART decrypted line ....... FAIL"); fails = fails + 1; end

        if (log_has("RESULT: PASS"))
            $display("CHECK UART final RESULT line .... PASS");
        else begin $display("CHECK UART final RESULT line .... FAIL"); fails = fails + 1; end

        if (framing_errors == 0) $display("CHECK UART framing ............... PASS");
        else begin $display("CHECK UART framing ............... FAIL (%0d errors)", framing_errors); fails = fails + 1; end

        if (baud_err_pct > -2.0 && baud_err_pct < 2.0)
            $display("CHECK baud error within 2%% ..... PASS");
        else begin $display("CHECK baud error within 2%% ..... FAIL"); fails = fails + 1; end

        if (fails == 0) $display("OVERALL: ALL CHECKS PASS (simulation only)");
        else            $display("OVERALL: %0d CHECK(S) FAILED", fails);
        $finish;
    end
endmodule
