set WORK_DIR  [pwd]
set BIT_FILE  top_24_07_24_18_33_12.bit

# PSU - Disable Security gates to view PMU MB target
puts "PSU - Disable Security gates to view PMU MB target"
connect
targets -set -nocase -filter {name =~ "*PSU*"}
mask_write 0xFFCA0038 0x1C0 0x1C0
targets

# Program PMU
puts "Program PMU"
targets -set -nocase -filter {name =~ "*MicroBlaze PMU*"}
dow  ${WORK_DIR}/platform/zynqmp_pmufw/pmufw.elf
puts "Running PMUFW application on target."
con

# FSBL
puts "Program FSBL"
targets -set -nocase -filter {name =~ "*A53*#0"}
rst -processor -clear-registers
source ${WORK_DIR}/platform/hw/psu_init.tcl
dow    ${WORK_DIR}/platform/zynqmp_fsbl/fsbl_a53.elf
puts "Running FSBL application on target."
con
after 4000
stop

# Reset PS-PL
psu_ps_pl_isolation_removal
psu_ps_pl_reset_config

# Program FPGA
targets -set -nocase -filter {name =~ "*PL*"}
fpga ./../pl/artf/${BIT_FILE}
