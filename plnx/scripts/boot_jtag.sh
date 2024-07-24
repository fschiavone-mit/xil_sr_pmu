#!/bin/bash

PLNX_PROJ_NAME=sr_plnx
WORK_DIR=$(pwd)
PLNX_PROJ_DIR=${WORK_DIR}/${PLNX_PROJ_NAME}
TCL_NAME=petalinux-boot-jtag.tcl
TCL_DIR=${WORK_DIR}/scripts/xsdb
TCL_FILE=${TCL_DIR}/${TCL_NAME}

cd ${PLNX_PROJ_DIR}
petalinux-boot -p ${PLNX_PROJ_DIR} --jtag --prebuilt 2 --tcl ${TCL_FILE} --verbose >> /var/log/${PLNX_PROJ_NAME}/bootlog-jtag-`date +%F-%T`.log
cd ${WORK_DIR}