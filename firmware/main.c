#include <stdint.h>

/* ------------------------------------------------------------------
 * Board / UART configuration  (change ONLY these two if the clock changes)
 * ------------------------------------------------------------------ */
#define CLK_HZ   50000000u       /* PicoSoC system clock: 50 MHz  */
#define BAUD     115200u         /* 8N1, no flow control          */

/* simpleuart sends one bit every (divider + 2) system clocks
   (shifts when send_divcnt > divider; verified by measurement in sim). */
#ifndef UART_DIV_VALUE
#define UART_DIV_VALUE  (((CLK_HZ + (BAUD / 2u)) / BAUD) - 2u)
#endif

/* ------------------------------------------------------------------
 * PicoSoC peripherals
 * ------------------------------------------------------------------ */
#define UART_DIV   (*(volatile uint32_t *)0x02000004u)
#define UART_DATA  (*(volatile uint32_t *)0x02000008u)

#define AES_BASE    0x03000000u
#define AES_CTRL    (*(volatile uint32_t *)(AES_BASE + 0x00))
#define AES_STATUS  (*(volatile uint32_t *)(AES_BASE + 0x04))
#define AES_DATA0   (*(volatile uint32_t *)(AES_BASE + 0x08))
#define AES_DATA1   (*(volatile uint32_t *)(AES_BASE + 0x0C))
#define AES_DATA2   (*(volatile uint32_t *)(AES_BASE + 0x10))
#define AES_DATA3   (*(volatile uint32_t *)(AES_BASE + 0x14))
#define AES_KEY0    (*(volatile uint32_t *)(AES_BASE + 0x18))
#define AES_KEY1    (*(volatile uint32_t *)(AES_BASE + 0x1C))
#define AES_KEY2    (*(volatile uint32_t *)(AES_BASE + 0x20))
#define AES_KEY3    (*(volatile uint32_t *)(AES_BASE + 0x24))
#define AES_OUT0    (*(volatile uint32_t *)(AES_BASE + 0x28))
#define AES_OUT1    (*(volatile uint32_t *)(AES_BASE + 0x2C))
#define AES_OUT2    (*(volatile uint32_t *)(AES_BASE + 0x30))
#define AES_OUT3    (*(volatile uint32_t *)(AES_BASE + 0x34))

/* Result word in RAM address 0 (checked by the simulation testbench) */
volatile uint32_t aes_test_result;

#define RESULT_PASS             0xA35E0001u
#define RESULT_ENC_MISMATCH     0xA35E0002u
#define RESULT_DEC_MISMATCH     0xA35E0003u
#define RESULT_ENC_TIMEOUT      0xA35E0004u
#define RESULT_DEC_TIMEOUT      0xA35E0005u

#define TIMEOUT_LIMIT  1000000u

/* 128-bit values, least-significant 32-bit word first */
static const uint32_t PT[4]     = {0xCCDDEEFFu, 0x8899AABBu, 0x44556677u, 0x00112233u};
static const uint32_t KEY[4]    = {0x0C0D0E0Fu, 0x08090A0Bu, 0x04050607u, 0x00010203u};
static const uint32_t CT_REF[4] = {0x70B4C55Au, 0xD8CDB780u, 0x6A7B0430u, 0x69C4E0D8u};

/* ---------------- UART ---------------- */
static void uart_putc(char c)
{
    UART_DATA = (uint32_t)(uint8_t)c;   /* bus stalls while UART is busy */
}

static void uart_puts(const char *s)
{
    while (*s) uart_putc(*s++);
}

static void uart_puthex32(uint32_t x)
{
    int i;
    for (i = 7; i >= 0; i--) {
        uint32_t n = (x >> (i * 4)) & 0xFu;
        uart_putc((char)(n < 10u ? ('0' + n) : ('A' + n - 10u)));
    }
}

/* prints a 128-bit value as W3 W2 W1 W0 (do not reverse the words) */
static void print_block(const char *label, const uint32_t w[4])
{
    uart_puts(label);
    uart_puthex32(w[3]);
    uart_puthex32(w[2]);
    uart_puthex32(w[1]);
    uart_puthex32(w[0]);
    uart_puts("\r\n");
}

/* ---------------- AES ---------------- */
static void aes_start(const uint32_t d[4], const uint32_t k[4], uint32_t mode)
{
    AES_DATA0 = d[0]; AES_DATA1 = d[1]; AES_DATA2 = d[2]; AES_DATA3 = d[3];
    AES_KEY0  = k[0]; AES_KEY1  = k[1]; AES_KEY2  = k[2]; AES_KEY3  = k[3];
    AES_CTRL  = (mode << 1) | 1u;       /* mode 0 = encrypt, 1 = decrypt */
}

static int aes_wait_done(void)
{
    uint32_t timeout = TIMEOUT_LIMIT;
    while ((AES_STATUS & 1u) == 0u) {
        if (--timeout == 0u) return 0;
    }
    return 1;
}

static void aes_read(uint32_t o[4])
{
    o[0] = AES_OUT0; o[1] = AES_OUT1; o[2] = AES_OUT2; o[3] = AES_OUT3;
}

static int equal128(const uint32_t a[4], const uint32_t b[4])
{
    return a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3];
}

static void finish(uint32_t code)
{
    aes_test_result = code;
    for (;;) {}
}

int main(void)
{
    uint32_t out[4];

    UART_DIV = UART_DIV_VALUE;          /* must be set before any output */

    uart_puts("\r\nPicoRV32 AES-128 self-test\r\n");
    print_block("Plaintext  = ", PT);
    print_block("Key        = ", KEY);

    /* ---- encryption ---- */
    aes_start(PT, KEY, 0u);
    if (!aes_wait_done()) {
        uart_puts("ENC TIMEOUT\r\n");
        finish(RESULT_ENC_TIMEOUT);
    }
    aes_read(out);
    print_block("Ciphertext = ", out);
    if (!equal128(out, CT_REF)) {
        uart_puts("ENC FAIL\r\n");
        finish(RESULT_ENC_MISMATCH);
    }
    uart_puts("ENC PASS\r\n");

    /* ---- decryption: input is the ciphertext the hardware produced ---- */
    uint32_t ct[4];
    ct[0] = out[0]; ct[1] = out[1]; ct[2] = out[2]; ct[3] = out[3];

    aes_start(ct, KEY, 1u);
    if (!aes_wait_done()) {
        uart_puts("DEC TIMEOUT\r\n");
        finish(RESULT_DEC_TIMEOUT);
    }
    aes_read(out);
    print_block("Decrypted  = ", out);
    if (!equal128(out, PT)) {
        uart_puts("DEC FAIL\r\n");
        finish(RESULT_DEC_MISMATCH);
    }
    uart_puts("DEC PASS\r\nRESULT: PASS\r\n");

    finish(RESULT_PASS);
    return 0;
}
