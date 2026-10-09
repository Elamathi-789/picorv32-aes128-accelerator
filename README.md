# PicoRV32-Based AES-128 Hardware Accelerator for Secure Tactical Communication

## Overview

This project implements a hardware-accelerated AES-128 encryption and decryption system using the PicoRV32 RISC-V processor on a Boolean FPGA development board featuring the Xilinx Spartan-7 XC7S50 FPGA.

The system integrates a software-programmable AES-128 hardware accelerator with the PicoSoC through a Memory-Mapped I/O (MMIO) interface. The processor configures the accelerator, supplies plaintext or ciphertext and a 128-bit key, starts the cryptographic operation, and retrieves the result through memory-mapped registers.

The project aims to demonstrate how hardware acceleration can improve cryptographic processing for secure communication applications.

## Objectives

* Integrate an AES-128 hardware accelerator with a PicoRV32-based SoC.
* Implement AES encryption and decryption using dedicated hardware.
* Enable processor-to-accelerator communication through MMIO registers.
* Support firmware interaction and debugging through UART.
* Explore FPGA-based cryptographic acceleration for secure tactical communication systems.

## System Architecture

```text
                 +--------------------------+
                 |        Host PC            |
                 | Firmware / UART Terminal  |
                 +------------+-------------+
                              |
                         USB-UART
                              |
                 +------------v-------------+
                 |     Boolean FPGA Board    |
                 |   Spartan-7 XC7S50 FPGA   |
                 |                           |
                 |  +---------------------+  |
                 |  |       PicoSoC       |  |
                 |  |                     |  |
                 |  |   PicoRV32 CPU      |  |
                 |  |   On-chip RAM       |  |
                 |  |   UART Peripheral   |  |
                 |  |   SPI Flash Access  |  |
                 |  +----------+----------+  |
                 |             | MMIO        |
                 |  +----------v----------+  |
                 |  |   AES MMIO Control  |  |
                 |  | Control / Status    |  |
                 |  | Data / Key Registers|  |
                 |  +----------+----------+  |
                 |             |             |
                 |  +----------v----------+  |
                 |  |   AES-128 Engine    |  |
                 |  |                     |  |
                 |  | Key Expansion       |  |
                 |  | AES Encryption      |  |
                 |  | AES Decryption      |  |
                 |  +---------------------+  |
                 +---------------------------+
                              |
                   +----------v----------+
                   | Encrypted Output    |
                   | Ciphertext (128-bit) |
                   +----------------------+
```

*Note: The diagram represents the intended system architecture. Actual firmware boot, FPGA pin assignments, and hardware operation must be verified on the target board.*

## Hardware Platform

* **FPGA:** Xilinx Spartan-7 XC7S50
* **Development board:** Real Digital Boolean Board
* **Processor:** PicoRV32 RISC-V CPU
* **Communication interface:** UART
* **Firmware storage interface:** SPI flash through `spimemio`
* **Cryptographic accelerator:** AES-128 encryption/decryption engine

## Main Components

### 1. PicoRV32 Processor

PicoRV32 is a compact RISC-V processor that executes the firmware and controls the AES accelerator. It initiates cryptographic operations and reads the resulting data from the accelerator.

### 2. PicoSoC

PicoSoC integrates the processor with on-chip RAM, UART, and SPI flash access. It provides the processor's memory and peripheral interfaces.

### 3. AES MMIO Controller

The AES MMIO controller connects the processor to the cryptographic engine through memory-mapped registers. The firmware uses these registers to configure an operation, provide input data and key material, initiate processing, and read the result and status.

### 4. AES-128 Hardware Engine

The AES engine performs encryption and decryption on 128-bit data blocks using a 128-bit key. The dedicated hardware implementation is intended to reduce the processor's workload compared with performing all cryptographic rounds in software.

### 5. UART Interface

UART provides a serial communication path between the FPGA and a host computer. It can be used for firmware interaction, debugging, and displaying test results.

### 6. SPI Flash Interface

The `spimemio` module allows PicoSoC to read program instructions from external SPI flash. Successful firmware boot depends on the flash configuration, memory layout, board wiring, and firmware image placement.

## Memory-Mapped I/O

The AES peripheral is instantiated with the following base address in the current top-level RTL:

| Parameter     | Address      |
| ------------- | ------------ |
| AES MMIO base | `0x03000000` |

The precise register offsets, access permissions, start/done behavior, and data layout must match the implementation in `aes_mmio.v` and the firmware.

## Expected Operation

1. Build the firmware for the PicoRV32 processor.
2. Configure the FPGA with the synthesized and implemented bitstream.
3. Initialize or boot the firmware from the configured memory source.
4. Send test inputs and a 128-bit key to the accelerator through MMIO registers.
5. Start the AES encryption or decryption operation.
6. Wait for the accelerator to signal completion.
7. Read and verify the 128-bit result.
8. Use UART to display or capture test results.

## Repository Structure

The following is a suggested organization; adjust it to match the files in your repository.

```text
.
├── rtl/
│   ├── picosoc.v
│   ├── picorv32.v
│   ├── simpleuart.v
│   ├── spimemio.v
│   ├── picosoc_aes.v
│   ├── aes_mmio.v
│   └── aes_v3_enc_dec_top.v
├── firmware/
│   ├── main.c
│   └── [firmware build files]
├── constraints/
│   └── boolean_board.xdc
├── simulation/
│   └── [testbenches]
├── README.md
└── LICENSE
```

## Tools Required

* AMD Xilinx Vivado Design Suite
* A RISC-V-compatible firmware compiler, such as a `riscv32-unknown-elf` toolchain compatible with the selected ISA
* A serial terminal application
* Boolean FPGA development board and USB programming connection

## Verification and Testing

The following tests should be completed before claiming successful hardware operation:

* [ ] RTL elaboration and synthesis complete without errors.
* [ ] FPGA implementation completes and timing requirements are met.
* [ ] Clock, UART, reset, and SPI flash pin assignments are verified against official board documentation.
* [ ] AES encryption results match known-answer test vectors.
* [ ] AES decryption recovers the original plaintext.
* [ ] MMIO register accesses work correctly.
* [ ] Firmware boot from SPI flash is verified, if used.
* [ ] UART communication is verified on the physical board.

## Security Considerations

AES-128 is a standardized symmetric block cipher. However, using AES hardware alone does not establish a complete secure communication system.

A deployed system also requires secure key management, appropriate operation modes, message authentication, nonce or IV handling where applicable, and protection against implementation-specific side-channel attacks. Integration with an actual tactical radio or communication link is outside the scope of the currently described FPGA architecture unless implemented separately.

## Project Status

**Development stage:** FPGA integration and verification.

The project RTL includes a PicoSoC wrapper, an AES MMIO interface, and an AES encryption/decryption engine. Synthesis, timing closure, firmware boot, and on-board functional testing should be documented as they are completed.

## Future Improvements

* Complete FPGA timing analysis and resource utilization analysis.
* Automate firmware loading and regression testing.
* Add authenticated encryption or message authentication.
* Evaluate latency, throughput, and resource usage against a software-only AES implementation.
* Integrate with a suitable communication interface for end-to-end secure data transfer.

## License

Add the license appropriate to your project and the licenses of the third-party components used. Retain the original PicoRV32 and PicoSoC license notices when redistributing their source code.
