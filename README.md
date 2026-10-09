# PicoRV32-Based AES-128 Hardware Accelerator for Secure Tactical Communication

## Project Overview

This project aims to design and implement a hardware-accelerated AES-128 encryption system integrated with the PicoRV32 RISC-V processor on an FPGA platform.

The PicoRV32 processor controls the encryption process, while a custom AES-128 hardware accelerator performs encryption of 128-bit data blocks using a 128-bit secret key. The processor communicates with the accelerator through a memory-mapped register interface.

The goal is to explore hardware acceleration, processor–accelerator integration, RTL design, functional verification, and secure data communication.

## Objectives

* Integrate the PicoRV32 RISC-V processor with a custom AES-128 hardware accelerator.
* Design the AES-128 encryption logic using Verilog HDL.
* Develop a register interface for data, key, control, and status signals.
* Verify AES encryption using simulation and standard test vectors.
* Evaluate FPGA resource utilization and encryption performance.
* Demonstrate encrypted data transfer through a supported communication interface.

## Proposed Architecture

The system consists of the following major blocks:

1. **PicoRV32 CPU:** Executes firmware and controls the accelerator.
2. **Instruction and Data Memory:** Stores the program, input data, and working variables.
3. **System Bus / Register Interface:** Transfers commands, plaintext, keys, and ciphertext between the CPU and accelerator.
4. **AES-128 Hardware Accelerator:** Performs AES encryption using a 128-bit key and 128-bit data block.
5. **Control and Status Registers:** Start encryption and indicate busy or completion status.
6. **Communication Interface:** Provides a possible path for transferring encrypted data to an external device.

The exact bus connection and memory map will be determined from the selected PicoRV32 system design.

## AES-128 Encryption Flow

1. The processor loads a 128-bit plaintext block and a 128-bit secret key.
2. The processor writes the input values into the accelerator registers.
3. The processor starts the encryption operation.
4. The AES hardware performs the required encryption rounds and key expansion.
5. The accelerator indicates completion.
6. The processor reads the 128-bit ciphertext.
7. The ciphertext can be transferred through a supported communication interface.

## Development Plan

* [ ] Study the provided PicoRV32 RTL and interface.
* [ ] Implement the AES-128 encryption core in Verilog.
* [ ] Create a testbench and verify the AES core.
* [ ] Design the accelerator control and register interface.
* [ ] Integrate the accelerator with PicoRV32.
* [ ] Develop firmware to control encryption.
* [ ] Simulate and debug the integrated system.
* [ ] Implement the design on an FPGA, subject to platform availability.
* [ ] Measure FPGA resource usage and performance.

## Tools and Technologies

* Verilog HDL
* RISC-V PicoRV32 processor
* RTL simulation and waveform analysis tools
* FPGA synthesis and implementation tools
* C firmware (planned)

## Expected Outcome

A working FPGA-based prototype demonstrating AES-128 hardware encryption controlled by a PicoRV32 RISC-V processor, with simulation-based functional verification and performance evaluation.

## Project Status

**Status:** Initial planning and architecture stage.

Implementation and verification results will be added as development progresses.

## Security Note

AES-128 encryption alone does not provide complete secure communication. A practical system may also require message authentication, secure key management, and a suitable communication protocol.
