# 特權同學 STAR board, XC7A35T-FTG256. Pins from the vendor's at7.xdc (see docs/BOARD.md).
# Uncomment a group when the top module has those ports.

set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33} [get_ports clk_50m]
set_property -dict {PACKAGE_PIN T2  IOSTANDARD LVCMOS33} [get_ports rst_n]

set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

# set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS33} [get_ports uart_rx]
# set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports uart_tx]

# set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
# set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
# set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
# set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
# set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
# set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
# set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
# set_property -dict {PACKAGE_PIN R8 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]
