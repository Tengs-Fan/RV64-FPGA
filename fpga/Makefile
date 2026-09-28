# openXC7 flow (D8): Yosys -> nextpnr-xilinx -> Project X-Ray -> .bit, all inside the container.
#   make              build build/$(TOP).bit
#   make prog         load it into the FPGA's SRAM (lost at power-off; the flash is untouched)
#   make TOP=x SRCS="../rtl/x.sv ..."   build another top module

TOP   ?= blinky
SRCS  ?= ../rtl/blinky.sv
XDC   ?= star.xdc
PART  ?= xc7a35tftg256-1
FREQ  ?= 50
# Defaults suit small designs; for BRAM or DSP use near 100 %, try PLACER=sa ROUTER=router1 (docs/BOARD.md).
PLACER ?= heap
ROUTER ?= router2

IMAGE  := docker.io/regymm/openxc7
ROOT   := $(abspath ..)
DB     := /nextpnr-xilinx/xilinx/external/prjxray-db/artix7
CHIPDB := build/chipdb/$(PART).bin
OFL    ?= $(shell command -v openFPGALoader || echo /home/linuxbrew/.linuxbrew/bin/openFPGALoader)

# Run a command in the container with the repository mounted at /work, as the calling user.
RUN := podman run --rm --security-opt label=disable --userns=keep-id -e HOME=/tmp \
	-v $(ROOT):/work -w /work/fpga $(IMAGE)

.PHONY: all prog clean
all: build/$(TOP).bit

# The chipdb takes about a minute and 93 MB per part; build it once.
$(CHIPDB):
	mkdir -p build/chipdb
	$(RUN) bash -c 'python3 /nextpnr-xilinx/xilinx/python/bbaexport.py --device $(PART) --bba $(CHIPDB:.bin=.bba) \
		&& bbasm -l $(CHIPDB:.bin=.bba) $(CHIPDB) && rm $(CHIPDB:.bin=.bba)'

build/$(TOP).json: $(SRCS)
	mkdir -p build
	$(RUN) yosys -q -l build/$(TOP).yosys.log \
		-p "read_verilog -sv $(SRCS); synth_xilinx -flatten -abc9 -arch xc7 -top $(TOP); write_json $@"

build/$(TOP).fasm: build/$(TOP).json $(XDC) $(CHIPDB)
	$(RUN) nextpnr-xilinx --chipdb $(CHIPDB) --xdc $(XDC) --json $< --fasm $@ \
		--freq $(FREQ) --placer $(PLACER) --router $(ROUTER) -l build/$(TOP).nextpnr.log

build/$(TOP).bit: build/$(TOP).fasm
	$(RUN) bash -c 'source /prjxray/env/bin/activate \
		&& fasm2frames --part $(PART) --db-root $(DB) $< > build/$(TOP).frames \
		&& xc7frames2bit --part_file $(DB)/$(PART)/part.yaml --part_name $(PART) \
			--frm_file build/$(TOP).frames --output_file $@'
	@grep -E "Max frequency" build/$(TOP).nextpnr.log || true

prog: build/$(TOP).bit
	$(OFL) -c digilent_hs2 $<

clean:
	rm -rf build/*.json build/*.fasm build/*.frames build/*.bit build/*.log
