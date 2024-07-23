set WORK_DIR  [pwd]
set PLNX_DIR  [pwd]
set WORKSPACE 0

puts "Initialize PSU"
connect
targets -set -nocase -filter {name =~ "*PSU*"}
mask_write 0xFFCA0038 0x1C0 0x1C0
targets

# Program PMU
puts "Program PMU"
targets -set -nocase -filter {name =~ "*MicroBlaze PMU*"}
dow  ${WORK_DIR}/platform/zynqmp_pmufw/pmufw.elf
con

# FSBL
puts "Program FSBL"
#targets 11
targets -set -nocase -filter {name =~ "*A53*#0"}
rst -processor -clear-registers
source ${PLNX_DIR}/project-spec/hw-description/psu_init.tcl
dow  ${WORK_DIR}/platform/zynqmp_fsbl/fsbl_a53.elf

con
after 4000
stop

# Program FPGA
targets -set -nocase -filter {name =~ "*PL*"}
fpga ${WORK_DIR}/platform/hw/xsa_24_06_13_15_07_36.bit

