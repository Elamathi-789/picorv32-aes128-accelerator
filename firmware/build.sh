#!/bin/bash
set -e

CC=riscv64-unknown-elf-gcc
OBJCOPY=riscv64-unknown-elf-objcopy
OBJDUMP=riscv64-unknown-elf-objdump
SIZE=riscv64-unknown-elf-size

CFLAGS="-march=rv32imc -mabi=ilp32 -O2 -Wall -Wextra -ffreestanding -fno-builtin -fno-stack-protector"
LDFLAGS="-march=rv32imc -mabi=ilp32 -nostdlib -nostartfiles -T linker.ld -Wl,--build-id=none -Wl,-Map=firmware.map"

echo "Compiling PicoRV32 AES firmware..."

$CC $CFLAGS -c start.S -o start.o
$CC $CFLAGS -c main.c -o main.o

$CC $LDFLAGS start.o main.o -lgcc -o firmware.elf

$OBJCOPY -O binary firmware.elf firmware.bin
$OBJCOPY -O ihex firmware.elf firmware.hex
$OBJDUMP -d firmware.elf > firmware.dis
$SIZE firmware.elf

echo "Build completed."
echo "Generated: firmware.elf, firmware.bin, firmware.hex, firmware.dis"
