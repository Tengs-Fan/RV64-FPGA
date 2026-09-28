# Roadmap

Each milestone ends in something observable.
Don't start a milestone until the previous one's "Done when" is true.

## Current position

**Milestone:** M0, not started. Software side: `sw/hello` builds with Zig 0.16.0 (`cd sw && zig build`); `zig build run` boots it on QEMU (needs `qemu-system-riscv`).
**Next action:** identify the board's clock, LED, and UART pins, then blink an LED through the openXC7 flow (D8); meanwhile, on QEMU, grow `sw/` into a trap handler with timer interrupts (practice for M3).
**Open questions:** see the bottom of this file.

## Milestones

### M0. Board bring-up

- [ ] `make` in `fpga/` builds a bitstream with the openXC7 container (D8).
- [ ] Board pinout known: clock pin and frequency, one LED, two pins for UART.
- [ ] LED blinks.
- [ ] A hardware-only UART transmitter prints a repeating character in `picocom`.

Done when: characters from the FPGA appear in `picocom`.

### M1. RV64I core in simulation

- [ ] 5-stage pipeline with forwarding and hazard stalls (D3).
- [ ] Verilator testbench loads an ELF into memory and stops on a pass/fail signal.
- [ ] All `rv64ui-p-*` tests from `riscv-tests` pass.
- [ ] Spike log comparison runs and matches on a small Zig program.

Done when: `make test` runs every `rv64ui` test green.

### M2. First software on hardware

- [ ] Core plus block RAM plus UART on the FPGA.
- [ ] A Zig program prints "hello" over UART.

Done when: the program's output appears in `picocom`.

### M3. Machine mode

- [ ] Zicsr and machine-mode CSRs, exceptions, `mret`.
- [ ] CLINT timer and timer interrupts.
- [ ] M extension (mul/div).
- [ ] `rv64mi-p-*` and `rv64um-p-*` tests pass.

Done when: a timer interrupt handler runs periodically on the FPGA.

### M4. Boot ROM loader

- [ ] Boot ROM receives a binary over UART into RAM and jumps to it.
- [ ] Host-side script sends a program.

Done when: new software runs without rebuilding the bitstream.

### M5. Tiny kernel (machine mode only)

- [ ] Preemptive round-robin threads driven by the timer.
- [ ] A small shell over UART.
- [ ] Same binary runs on QEMU `virt` and on the FPGA (D4, D5).

Done when: the shell runs on both.

### M6. Real OS features

- [ ] Supervisor and user modes, trap delegation.
- [ ] Sv39 page-table walker and a TLB.
- [ ] A extension (atomics).
- [ ] `rv64si-p-*` and `rv64ua-p-*` tests pass.
- [ ] OS with user processes, system calls, and virtual memory.

Done when: user programs run in their own address spaces on the FPGA.

### M7. Caches and DDR (may need a board with DDR, such as an XC7A100T board)

- [ ] Instruction and data caches behind the D3 memory interface.
- [ ] DDR controller (Xilinx MIG or LiteDRAM).

### M8. Stretch: Linux

- [ ] OpenSBI in machine mode, Linux kernel built without FPU, Buildroot rv64ima user space.

## Open questions

- Board name and pinout. Is there DDR on it?
- Exact part number from the chip marking; the `a7-50t-probe` experiment assumed `xc7a35tcsg324-1`.
- Is the PL2303 cable 3.3 V or 5 V?

## Session log

Newest first. One or two lines per session: what changed, what's next.

- 2026-09-28: switched the FPGA flow to openXC7, Vivado only as a fallback (D8).
- 2026-09-28: switched software to Zig (D7); added `sw/` with `build.zig`, linker script, and a hello program for QEMU virt; added the test finisher to the memory map (D4).
- 2026-09-28: project created; decisions D1–D10 and this roadmap written. Next: M0.
