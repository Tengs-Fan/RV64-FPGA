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
Zig can target any extension combination, so software doesn't force C (D7).

## D3. Microarchitecture: classic 5-stage in-order pipeline

Single issue, full forwarding, static not-taken branch prediction, multi-cycle mul/div that stalls the pipeline.
The key rule: instruction fetch and data access each go through a request/response (valid/ready) memory interface from day one, even when backed by 1-cycle block RAM.
That lets us swap block RAM for caches and DDR later without rewriting the pipeline.

## D4. Memory map: a subset of QEMU's `virt` machine

| Address | Device |
|---|---|
| `0x0000_1000` | Boot ROM: UART program loader |
| `0x0010_0000` | Test finisher: write `0x5555` = pass and stop, `(code << 16) \| 0x3333` = fail. QEMU exits; the Verilator testbench ends the simulation. |
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

## D7. Software: Zig 0.16.0 and assembly, freestanding

The OS and test programs are written in Zig; the boot entry, trap entry, and ISA tests stay in assembly.
Pin Zig 0.16.0 (`dnf install zig` on Fedora 44) and don't upgrade mid-project: Zig is pre-1.0 and breaks APIs between releases.
Build for exactly the extensions the core implements, for example `-target riscv64-freestanding-none -mcpu=generic_rv64-c-m-a-f-d -mcmodel=medium` for plain RV64I; add `+m`, `+a` as the core gains them.
Zig ships its own runtime helpers (`compiler_rt`) built for that exact target, so before the M extension exists, multiplication calls a software `__muldi3` automatically.
Verified 2026-09-28: a freestanding test kernel built this way contained no M or C instructions and called `__muldi3`/`__udivdi3`.
Pitfall (Zig and C alike): code linked at `0x8000_0000` needs the medany code model (`-mcmodel=medium` in Zig, `-mcmodel=medany` in C); the default fails with "relocation R_RISCV_HI20 out of range".
Reference material such as xv6-riscv is in C; read it, write ours in Zig.
Fallback: C with Fedora's `gcc-riscv64-linux-gnu` and `-ffreestanding -nostdlib`, without linking the distro's `libgcc` (built for rv64gc).

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
- 2026-09-28: D7 switched from C to Zig at the user's request, after a test build confirmed plain-RV64I output.
