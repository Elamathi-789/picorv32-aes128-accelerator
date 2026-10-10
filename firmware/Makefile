# PicoRV32 AES-128 firmware build
# Commands start with '>' (see .RECIPEPREFIX) so no tab characters are needed.
.RECIPEPREFIX = >

CC      = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump
SIZE    = riscv64-unknown-elf-size

CFLAGS  = -march=rv32imc -mabi=ilp32 -O2 -Wall -Wextra -ffreestanding -fno-builtin -fno-stack-protector
LDFLAGS = -march=rv32imc -mabi=ilp32 -nostdlib -nostartfiles -T linker.ld -Wl,--build-id=none -Wl,-Map=firmware.map

all: firmware_mem.hex

start.o: start.S
> $(CC) $(CFLAGS) -c start.S -o start.o

main.o: main.c
> $(CC) $(CFLAGS) -c main.c -o main.o

firmware.elf: start.o main.o linker.ld
> $(CC) $(LDFLAGS) start.o main.o -lgcc -o firmware.elf
> $(SIZE) firmware.elf

firmware.bin: firmware.elf
> $(OBJCOPY) -O binary firmware.elf firmware.bin
> $(OBJCOPY) -O ihex firmware.elf firmware.hex
> $(OBJDUMP) -d firmware.elf > firmware.dis

firmware_mem.hex: firmware.bin make_images.py
> python3 make_images.py

sim: firmware_mem.hex
> ./run_firmware_sim.sh | tee sim_pass_log.txt

clean:
> rm -f start.o main.o firmware.elf firmware.bin firmware.hex firmware.dis firmware.map firmware_words.hex firmware_mem.hex

.PHONY: all sim clean
