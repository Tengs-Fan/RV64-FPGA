# Board

What is known about the FPGA board, measured over JTAG from the Y9000P host (Fedora 44).
Facts are dated; re-measure before relying on anything marked unknown.

## Chip

| Item | Value | How known |
|---|---|---|
| Part | Xilinx Artix-7 XC7A35T | JTAG IDCODE `0x0362D093` (2026-09-24) |
| Device DNA | `0x00022c002428c854` | `openFPGALoader --read-dna` |
| Package, speed grade | unknown | Not readable over JTAG; read the chip marking. `xc7a35tcsg324-1` so far is an assumption. |
| Board name, clock, LEDs, pins | unknown | See "Open questions" in [ROADMAP.md](ROADMAP.md) |
| Boot mode | Master SPI (M[2:0] = `001`) | STAT register `0x401079fc`: the board configures itself from its SPI flash at power-up |
| Flash contents | A user design, loaded and running | DONE = 1, no CRC or ID error, MMCM locked (2026-09-24) |

Health reading from the on-chip XADC (2026-09-24): 31 °C, VCCINT 1.033 V (nominal 1.0), VCCAUX 1.828 V (nominal 1.8).

## JTAG programmer

- Digilent FT232H, USB `0403:6014`, product string "Digilent USB Device", serial `210241179917`.
- It has a single channel, used for JTAG. The `/dev/ttyUSB0` it creates is not a console; the console is the separate PL2303 cable (D9).
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
- Generating the chipdb (`bbaexport.py` + `bbasm`) takes about a minute and yields a 93 MB `xc7a35tcsg324-1.bin`; cache it rather than regenerating per build.
