# Roadmap

Each milestone ends in something observable.
Don't start a milestone until the previous one's "Done when" is true.

## Current position

**Milestone:** M0, not started. Software side: `sw/hello` builds with Zig 0.16.0 (`cd sw && zig build`); `zig build run` boots it on QEMU (needs `qemu-system-riscv`).
**Next action:** blink an LED through the openXC7 flow (D8) for `xc7a35tftg256-1`; pins are in [BOARD.md](BOARD.md) (clock N11, LED0 M1, UART P10/P11); meanwhile, on QEMU, grow `sw/` into a trap handler with timer interrupts (practice for M3).
**Open questions:** see the bottom of this file.

## Milestones

### M0. Board bring-up

- [ ] `make` in `fpga/` builds a bitstream with the openXC7 container (D8).
- [x] Board pinout known: clock pin and frequency, one LED, two pins for UART (2026-09-28, see BOARD.md).
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

### M7. Caches and DDR (the STAR board has 256 MB of DDR3, MT41K128M16JT on bank 15)

- [ ] Instruction and data caches behind the D3 memory interface.
- [ ] DDR controller (Xilinx MIG or LiteDRAM).

### M8. Stretch: Linux

- [ ] OpenSBI in machine mode, Linux kernel built without FPU, Buildroot rv64ima user space.

## Open questions

- Speed grade from the chip marking (probably -1).
- Jumper P2 setting (bank 35 at 2.5 V or 3.3 V), before using the PMOD or LVDS pins.

## Session log

Newest first. One or two lines per session: what changed, what's next.

- 2026-09-28: identified the board as 特權同學 STAR (XC7A35T-FTG256, 50 MHz clock, on-board PL2303 at 3.3 V, 256 MB DDR3) from the vendor files; recorded pins and bank voltages in BOARD.md; backed up the factory flash. Next: LED blink.
- 2026-09-28: added `docs/BOARD.md` with the JTAG measurements of the board, the 50T-BRAM finding, and openXC7 pitfalls. Board name and pinout still unknown.
- 2026-09-28: switched the FPGA flow to openXC7, Vivado only as a fallback (D8).
- 2026-09-28: switched software to Zig (D7); added `sw/` with `build.zig`, linker script, and a hello program for QEMU virt; added the test finisher to the memory map (D4).
- 2026-09-28: project created; decisions D1–D10 and this roadmap written. Next: M0.
