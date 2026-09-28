# rv64-fpga

A 64-bit RISC-V processor designed from scratch in SystemVerilog, running on a Xilinx Artix-7 XC7A35T FPGA, with a small operating system and software written for it.
This is a learning project.

## Resuming work

1. Read [docs/ROADMAP.md](docs/ROADMAP.md), "Current position", then the latest entries in its session log.
2. Read [docs/DECISIONS.md](docs/DECISIONS.md) for why things are the way they are.
3. Do the next action; at the end of the session, update "Current position" and add a session-log line.

## Hardware

- FPGA: Xilinx Artix-7 XC7A35T (JTAG ID `0x0362D093`).
- Programmer: Digilent FT232H-based JTAG (`0403:6014`), used with `openFPGALoader -c digilent_hs2`.
- Console: PL2303 USB-serial cable on FPGA pins.

Details, measurements, and toolchain pitfalls: [docs/BOARD.md](docs/BOARD.md).
