# Navigate to base project directory (xil_sr)
# execute the follow command to build the project: vivado -source ./scripts/create_proj.tcl 

set WORK_DIR  [pwd]
set PROJ_DIR  vivado_project
set PROJ_NAME project_sr
set DEVICE    xczu28dr-ffvg1517-2-e
set BD_NAME   bd

create_project $PROJ_NAME ./$PROJ_DIR -part $DEVICE -force
set_property board_part xilinx.com:zcu111:part0:1.4 [current_project]

# Build Block Diagram
source ./scripts/bd_script.tcl
close_bd_design [get_bd_designs $BD_NAME]
make_wrapper -files [get_files $PROJ_DIR/${PROJ_NAME}.srcs/sources_1/bd/$BD_NAME/${BD_NAME}.bd] -top
add_files -norecurse $PROJ_DIR/${PROJ_NAME}.gen/sources_1/bd/$BD_NAME/hdl/${BD_NAME}_wrapper.v
update_compile_order -fileset sources_1

# Add Vivado IP
source ./scripts/clk_wiz_0.tcl

# Add HDL Source Files
add_files ./hdl/top.vhd
set_property top top [current_fileset]
update_compile_order -fileset sources_1

# Add Constraint Files 
add_files -fileset constrs_1 -norecurse ./constr/pinout.xdc
update_compile_order -fileset sources_1

# Build Project
launch_runs synth_1 -jobs 8
wait_on_run synth_1
launch_runs impl_1  -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "INFO: Build Complete"
