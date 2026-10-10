#!/usr/bin/env python3
# Run inside /mnt/d/RISCV/aes_firmware after ./build.sh
# Makes firmware_words.hex (32-bit words) and firmware_mem.hex (bytes @ flash offset 0x100000)
b = open('firmware.bin','rb').read()
b += b'\0' * ((-len(b)) % 4)
with open('firmware_words.hex','w') as f:
    for i in range(0, len(b), 4):
        f.write('%08x\n' % int.from_bytes(b[i:i+4], 'little'))
with open('firmware_mem.hex','w') as f:
    f.write('@00100000\n')
    for i in range(0, len(b), 16):
        f.write(' '.join('%02X' % x for x in b[i:i+16]) + '\n')
print(len(b), 'bytes ->', len(b)//4, 'words')
