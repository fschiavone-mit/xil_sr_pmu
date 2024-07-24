# xil_sr_pmu
PMU not initializing 

### Prerequisites
This project uses **Vivado 2023.2**

### Create Vivado Project and build bitstream

Navigate into the git repoistory's pl directory.
```
cd ./xil_sr_pmu/pl
```
Run the following command to invoke Vivado and source a tickle script from the command line:
```
vivado -mode batch -source ./scripts/create_proj.tcl 
```

### Create Vitis Project

Navigate into the git repoistory's vitis_workspace directory and start the Xilinx Software Commandline Tool (XSCT).
```
cd ./xil_sr_pmu/vitis_workspace
xsct
```
Run the following command to create to vitis platform and generate the bsp including the PMU and FSBL.
```
source ./scripts/create_prj.tcl
```

### Programming Binaries

Navigate into the git repoistory's vitis_workspace directory and start the Xilinx System Debugger (XSDB).
```
cd ./xil_sr_pmu/vitis_workspace
xsdb
```
Run the following command to configure the PL, PMFW and FSBL.
```
source ./scripts/xsdb_load_binaries.tcl
```
