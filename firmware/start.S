.section .text.init
.globl _start
.type _start, @function

_start:
    /* Initialize stack pointer */
    la sp, _stack_top

    /* Clear .bss */
    la t0, _bss_start
    la t1, _bss_end

clear_bss:
    bgeu t0, t1, copy_data_start
    sw zero, 0(t0)
    addi t0, t0, 4
    j clear_bss

copy_data_start:
    /* Copy initialized .data from FLASH to RAM */
    la t0, _data_load_start
    la t1, _data_start
    la t2, _data_end

copy_data:
    bgeu t1, t2, call_main
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j copy_data

call_main:
    call main

hang:
    j hang

.size _start, .-_start
