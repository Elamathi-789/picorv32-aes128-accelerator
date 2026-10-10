OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    RAM (rwx)  : ORIGIN = 0x00000000, LENGTH = 1K
    FLASH (rx) : ORIGIN = 0x00100000, LENGTH = 64K
}

SECTIONS
{
    .text : {
        *(.text.init)
        *(.text*)
        *(.rodata*)
    } > FLASH

    .data : {
        . = ALIGN(4);
        _data_start = .;
        *(.sdata*)
        *(.data*)
        . = ALIGN(4);
        _data_end = .;
    } > RAM AT > FLASH

    _data_load_start = LOADADDR(.data);

    .bss (NOLOAD) : {
        . = ALIGN(4);
        _bss_start = .;
        *(.sbss*)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > RAM

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
