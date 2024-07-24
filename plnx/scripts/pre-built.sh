#!/bin/bash

PLNX_PROJ_NAME=sr_plnx
WORK_DIR=$(pwd)
PLNX_PROJ_DIR=${WORK_DIR}/${PLNX_PROJ_NAME}

petalinux-package -p ${PLNX_PROJ_DIR} --prebuilt --force
