# Board

The board is 特權同學's **STAR** Artix-7 learning board ("STAR" silkscreen confirmed from a photo of the board) (STAR 學習板, schematics titled `AR7_*.SchDoc`, dated 2020-03-31).
Facts below come from the vendor's schematic and constraint files and from measurements over JTAG on the Y9000P host (Fedora 44); each says which.

Vendor material (not copied into this repo):
- `~/Library/CloudStorage/OneDrive-Personal/3-Archive/Archive/FPGA/09_STAR_开发板资料共享/`: schematic, PCB layers, 25 example Vivado projects (`project/at7_ex*.rar`), board test project, datasheets.
- `~/Documents/Obsidian Vault/Database/Manual/Artix7-STAR/`: the schematic PDF and the constraint files `at7.xdc` (all board I/O), `ddr3.xdc` (MIG output), `lvds.xdc`, `at7_vga.xdc`.

## Chip

| Item | Value | How known |
|---|---|---|
| Part | Xilinx Artix-7 XC7A35T, package **FTG256** | Schematic (`XC7A35T-FTG256`); the vendor's board-test bitstream header (`7a35tftg256`); JTAG IDCODE `0x0362D093` |
| nextpnr / prjxray part | `xc7a35tftg256-1` | Speed grade -1 is likely (the vendor's MIG file says `-1`) but not confirmed; read the chip marking |
| Device DNA | `0x00022c002428c854` | `openFPGALoader --read-dna` |
| Boot mode | Master SPI (M[2:0] = `001`) | STAT register `0x401079fc` |
| Configuration flash | Spansion S25FL032P, 4 MB, quad mode enabled | Schematic (`S25FL032P0XMFI011`) and JEDEC ID `01 02 15` read over JTAG |
| DDR3 | Micron MT41K128M16JT, 256 MB, x16, on bank 15 | Schematic; the vendor's `ddr3.xdc` is MIG output for 400 MHz, SSTL15 |

Health reading from the on-chip XADC (2026-09-24): 31 °C, VCCINT 1.033 V (nominal 1.0), VCCAUX 1.828 V (nominal 1.8).

The a7-50t-probe experiment (below) built for `xc7a35tcsg324-1`, the wrong package.
It still worked because it used no I/O pins and the die is the same; any design with pins must use `xc7a35tftg256-1`.

## I/O banks

From the schematic's power page:

| Bank | VCCO | What is on it | IOSTANDARD |
|---|---|---|---|
| 0 | 3.3 V | Configuration | |
| 14 | 3.3 V | 50 MHz clock, UART, LCD, QSPI flash, keys, 7-segment | `LVCMOS33` |
| 34 | 3.3 V | LEDs, switches, reset button, buttons | `LVCMOS33` |
| 15 | 1.5 V | DDR3 | `SSTL15` (MIG) |
| 35 | `VCC_IO35`: 2.5 V or 3.3 V, set by jumper P2 | PMOD connectors and LVDS pins (`lvds.xdc`) | Check P2 before using this bank |

The vendor files write `LVTTL` for the 3.3 V pins; `LVCMOS33` is the same voltage and is what nextpnr-xilinx supports.

## Pins for M0

From the vendor's `at7.xdc`, cross-checked against the schematic.

| Signal | Pin | Notes |
|---|---|---|
| `clk_50m` | N11 | 50 MHz oscillator X1, `IO_L13P_T2_MRCC_14` (clock-capable) |
| `rst_n` | T2 | Reset button `SYSRST_N`, active low |
| `led[0..7]` | M1, N1, P1, R2, T3, R5, R6, T7 | Bank 34 |
| `sw[0..7]` | M2, N2, R1, R3, T4, T5, R7, R8 | DIP switches, bank 34 |
| `uart_rx` (FPGA input) | P10 | From the PL2303's TXD |
| `uart_tx` (FPGA output) | P11 | To the PL2303's RXD |

## Console

The USB-serial chip is on the board: a PL2303HXD powered at 3.3 V, with its own USB Type-B connector (P15).
No level shifting or wiring is needed; plug a second USB cable into that connector.
On 2026-09-28 only the JTAG adapter was connected to the Y9000P, so the PL2303 did not show up in `lsusb`.

## Flash backup

The factory flash was dumped on 2026-09-28, before anything writes to it:

- Files: `~/fpga-backup/factory-flash.bin` on the Y9000P and `~/fpga-backup/star-factory-flash.bin` on the Mac, 4,194,304 bytes each (the whole chip).
- SHA-256: `b71d7a0c0b60b9c39dc8524c1cea05e94d91838da1ee373261e0d0bac752d08a` (two dumps matched).
- Contents: one uncompressed, unencrypted Vivado bitstream of 2,192,012 bytes at offset 0 (IDCODE `0x0362D093`), the rest erased.
- It is not the vendor's board-test design (`project/star_board_test.zip`, `at7.runs/impl_2/at7.bit`): same length, but about 11.5% of the bytes differ. Which design it is remains unknown.
- Restore: `openFPGALoader -c digilent_hs2 --fpga-part xc7a35tftg256 -f factory-flash.bin`.

Dumping needs `--fpga-part` because openFPGALoader loads a package-specific SPI bridge bitstream; the output file is a positional argument (`-o` means offset):
`openFPGALoader -c digilent_hs2 --fpga-part xc7a35tftg256 --dump-flash --file-size 4194304 out.bin`, then `--reset`.

## JTAG programmer

The programmer in the board's kit is a 特權-branded "Xilinx Platform Cable USB" box on a 14-pin ribbon (photo, 2026-09-28).
Genuine Platform Cables enumerate as `03fd:0008`; the adapter seen on the Y9000P enumerates as Digilent FT232H, so either this box is an FT232H-based clone or a different adapter was connected. `-c digilent_hs2` works either way.

- Digilent FT232H, USB `0403:6014`, product string "Digilent USB Device", serial `210241179917`.
- It has a single channel, used for JTAG. The `/dev/ttyUSB0` it creates is not a console; the console is the on-board PL2303 (see "Console").
- On the Y9000P, udev rule `99-openfpgaloader.rules` is installed and the user is in `plugdev` and `dialout`, so no root is needed.

## Tools on the Y9000P

Both come from Linuxbrew, under `/home/linuxbrew/.linuxbrew/bin/`, which is not on the `PATH` of non-interactive SSH sessions.

- openFPGALoader v1.1.1, cable `-c digilent_hs2`:
  - `--detect`, `--read-register STAT`, `--read-xadc`, `--read-dna` inspect the chip.
  - `openFPGALoader -c digilent_hs2 top.bit` loads to SRAM (lost at power-off).
  - `-f` writes the SPI flash and replaces the stored design; don't use it until our design is worth keeping.
  - `--reset` reconfigures the chip from flash, restoring the stored design.
- OpenOCD 0.12.0: the stock `interface/ftdi/digilent-hs2.cfg` looks for "Digilent Adept USB Device" and fails; override the description:

```sh
openocd -f interface/ftdi/digilent-hs2.cfg \
  -c "ftdi device_desc {Digilent USB Device}; adapter speed 1000; transport select jtag" \
  -c "jtag newtap xc7 tap -irlen 6 -expected-id 0x0362d093; init" \
  -c "irscan xc7.tap 0x02; puts [drscan xc7.tap 32 0]; shutdown"
```

`irscan 0x02` selects `USER1`, which a `BSCANE2 #(.JTAG_CHAIN(1))` in the design answers; this is the on-chip debug path of D8.

## Extra resources: the 35T carries 50T silicon

Project X-Ray maps the `xc7a35t` part onto the `xc7a50t` fabric, so nextpnr-xilinx offers 75 RAMB36E1 and 120 DSP48E1 sites instead of the datasheet's 50 and 90.
On 2026-09-24 a test design (`~/Projects/a7-50t-probe` on the Y9000P) filled all 75 RAMB36 sites, loaded with DONE = 1, and passed a write-and-read-back self-test in both bit polarities on 75 of 75 blocks.

Consequences for this project:
- Block RAM for the core can go up to 75 × 36 Kb (about 330 KiB) instead of 50 (225 KiB) with the openXC7 flow.
- It is outside AMD's specification, and Vivado (the fallback in D8) still limits the part to 35T resources. A design that uses more than 50 BRAMs cannot fall back to Vivado.
- DSPs and logic beyond the 35T limits were not verified (see below).

Suggestion: stay within 50 BRAMs until a design actually needs more, so the Vivado fallback stays open.

## openXC7 pitfalls found on this chip

Seen with the `docker.io/regymm/openxc7` image, nextpnr-xilinx on `xc7a35tcsg324-1`:

- With BRAM or DSP use near 100 %, the default HeAP placer ran for over 30 minutes without finishing; `--placer sa` placed the same design in minutes.
- The default router2 failed with `ERROR: Invalid global constant node 'INT_L_X0Y46/GND_WIRE'`; `--router router1` routed the same design.
- Designs with 60 or more DSP48E1s did not build: the SA placer reported `failed to place chain`, and router2 hit the same `GND_WIRE` error. Expect trouble with many DSPs; the M extension's multiplier should need only a few.
- Generating the chipdb (`bbaexport.py` + `bbasm`) takes about a minute and yields a 93 MB chipdb per part and package (build `xc7a35tftg256-1` for this board); cache it rather than regenerating per build.
