# USER_SI570_P
set_property PACKAGE_PIN J19  [get_ports user_si570_p]
set_property IOSTANDARD  LVDS [get_ports user_si570_p]
# USER_SI570_N
set_property PACKAGE_PIN J18  [get_ports user_si570_n]
set_property IOSTANDARD  LVDS [get_ports user_si570_n]

# CPU_RESET
set_property PACKAGE_PIN AF15     [get_ports cpu_reset]
set_property IOSTANDARD  LVCMOS18 [get_ports cpu_reset]

# System Reference
set_property PACKAGE_PIN U4     [get_ports sysref_in_diff_n]
set_property PACKAGE_PIN U5     [get_ports sysref_in_diff_p]

# FPGA_REFCLK_P
set_property PACKAGE_PIN AL16 [get_ports fpga_refclk_p]
set_property IOSTANDARD  LVDS [get_ports fpga_refclk_p]
# FPGA_REFCLK_N
set_property PACKAGE_PIN AL15 [get_ports fpga_refclk_n]
set_property IOSTANDARD  LVDS [get_ports fpga_refclk_n]

# SMA connector J95
set_property PACKAGE_PIN AP14 [get_ports ams_fpga_ref_clk]
set_property IOSTANDARD LVCMOS18 [get_ports ams_fpga_ref_clk]
