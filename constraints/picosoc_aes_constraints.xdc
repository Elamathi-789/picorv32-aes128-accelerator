
# =============================================S=====
# PicoRV32 + AES-128 - Boolean Board Constraints
# FPGA: XC7S50CSGA324-1
# ==================================================

# 100 MHz board clock
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]
create_clock -name sys_clk -period 10.000 [get_ports {clk}]

# USB-UART connection
# FPGA transmit -> PC receive
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {ser_tx}]

# PC transmit -> FPGA receive
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {ser_rx}]

# Reset button: Boolean Board button 0
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {resetn}]

# Configuration voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# ==================================================
# QSPI Flash - Boolean Board
# ==================================================

# Flash chip select
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {flash_csb}]

# QSPI data lines
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {flash_io0}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {flash_io1}]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {flash_io2}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {flash_io3}]

# IMPORTANT:
# Do not assign a normal PACKAGE_PIN to flash_clk.
# The QSPI clock requires dedicated configuration-clock
# handling through the STARTUPE2 primitive.
