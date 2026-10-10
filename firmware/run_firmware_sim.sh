#!/bin/bash
# Run from anywhere in WSL.  Does NOT modify any RTL file.
set -e
RTL=/mnt/d/RISCV/PicoRV32_AES128_VI/PicoRV32_AES128_VI
FW=/mnt/d/RISCV/aes_firmware
cd "$RTL/AES"
SRC="$FW/picosoc_firmware_tb_50MHz.v TB/spiflash.v RTL/SOC/picosoc_aes.v
 picosoc_src/picosoc.v picosoc_src/picorv32.v picosoc_src/spimemio.v picosoc_src/simpleuart.v
 Coimbined/aes_mmio.v Coimbined/aes_v3_enc_dec_top.v Coimbined/aes_v3_enc_dec_controller.v
 $(ls RTL/encryption_reference/*.v | grep -v _tb) $(ls RTL/decryption/*.v | grep -v _tb)"
iverilog -g2012 -s picosoc_firmware_tb -o /tmp/fw_sim $SRC
vvp /tmp/fw_sim +firmware=$FW/firmware_mem.hex
