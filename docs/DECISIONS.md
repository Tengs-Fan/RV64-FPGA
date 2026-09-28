# Decisions

Coarse technology choices for the project.
Each entry says what we chose, why, and what would make us revisit it.
To change a decision, edit its entry and add a dated line under "Changes" rather than silently rewriting it.

## D1. HDL: SystemVerilog (synthesizable subset)

Chosen because the previous MIPS pipeline was in Verilog, Vivado and Verilator both take it natively, and what we debug (simulation waveforms, the on-chip ILA in Vivado) shows the signal names we wrote.
Rejected Chisel for now: it adds a Scala/sbt toolchain, and debugging means reading generated Verilog.
Revisit if parameterizing caches or the MMU becomes painful in plain SystemVerilog.

## D2. ISA target: grow RV64I step by step

Order: RV64I → Zicsr + M-mode traps → M (mul/div) → S/U modes + Sv39 MMU → A (atomics).
No C (compressed), F, or D (floating point): they cost area and complexity without teaching much new.
Linux, if we get there, can run without an FPU (kernel built without FPU support, user space built for rv64ima).
Revisit C if we want an off-the-shelf Rust target (Rust's bare-metal RV64 targets assume C).

## D3. Microarchitecture: classic 5-stage in-order pipeline

Single issue, full forwarding, static not-taken branch prediction, multi-cycle mul/div that stalls the pipeline.
The key rule: instruction fetch and data access each go through a request/response (valid/ready) memory interface from day one, even when backed by 1-cycle block RAM.
That lets us swap block RAM for caches and DDR later without rewriting the pipeline.

## D4. Memory map: a subset of QEMU's `virt` machine

| Address | Device |
|---|---|
| `0x0000_1000` | Boot ROM: UART program loader |
| `0x0200_0000` | CLINT: `mtime`, `mtimecmp`, software interrupt |
| `0x1000_0000` | UART: minimal 16550-compatible subset |
| `0x8000_0000` | RAM (block RAM now, DDR later) |

Chosen so the same OS binary runs both on `qemu-system-riscv64 -machine virt` and on our CPU.
No interrupt controller (PLIC) until a device other than the timer needs interrupts.

## D5. Develop the OS on QEMU in parallel with the CPU

The OS and the CPU meet in the middle.
QEMU gives a debugger and a known-good CPU, so a bug that appears only on our hardware is a hardware bug.

## D6. Verification: Verilator plus a golden model

Verilator runs the core in simulation with a C++ testbench, and GTKWave shows waveforms.
The official `riscv-tests` suite checks each instruction.
Spike, the reference RISC-V simulator (built from source, since Fedora doesn't package it), runs the same program, and we compare the two instruction-by-instruction logs of retired instructions and register writes.
The first line where they differ points at the bug.
Formal checking with riscv-formal is optional, later.

## D7. Software: C and assembly, freestanding

Compiler: Fedora's `gcc-riscv64-linux-gnu` (or clang), always with `-ffreestanding -nostdlib`, with explicit `-march`/`-mabi` matching what the core implements (for example `-march=rv64i_zicsr -mabi=lp64`).
Pitfall: the distro's `libgcc` is built for rv64gc, so don't link it; provide our own multiply/divide helpers until the M extension exists.
Rust is optional later (see D2).

## D8. FPGA flow: Vivado in batch mode, openFPGALoader to program

Vivado (free Standard edition, only Artix-7 installed) runs inside an Ubuntu 24.04 distrobox, driven by a Tcl script from a Makefile, not the GUI project mode.
`openFPGALoader -c digilent_hs2` loads bitstreams.
Start at 50 MHz from a clock manager (MMCM); raise it only after timing is met.

## D9. Console: UART on FPGA pins through the PL2303 cable

Check that the cable's logic level is 3.3 V and matches the I/O bank voltage of the pins used before connecting.
TX of the cable goes to the FPGA's RX pin and vice versa.

## D10. Repository layout

| Directory | Contents |
|---|---|
| `rtl/` | SystemVerilog for the core and SoC |
| `sim/` | Verilator testbench, test runners, Spike comparison |
| `sw/` | Boot ROM, test programs, the OS |
| `fpga/` | Constraints (XDC), Vivado Tcl, build and program scripts |
| `docs/` | This file, the roadmap, notes |

## Changes

- 2026-09-28: initial decisions.
