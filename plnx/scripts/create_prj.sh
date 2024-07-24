#!/bin/bash

PLNX_PROJ_NAME=sr_plnx
echo "PLNX_PROJ_NAME: ${PLNX_PROJ_NAME}"

petalinux-create -t project -n ${PLNX_PROJ_NAME} --template zynqMP
