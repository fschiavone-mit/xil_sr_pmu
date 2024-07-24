#!/bin/bash

# Import the new XSA from Vivado to Petalinux

PLNX_PROJ_NAME=sr_plnx
WORK_DIR=$(pwd)
PLNX_PROJ_DIR=${WORK_DIR}/${PLNX_PROJ_NAME}
PLNX_CONFIG_DIR=${PLNX_PROJ_DIR}/project-spec/configs
VIVADO_ARTF_DIR=${WORK_DIR}/../pl/artf/
XSA_NAME=xsa_24_07_24_16_07_50.xsa
VIVADO_XSA_FILE=${VIVADO_ARTF_DIR}/${XSA_NAME}
TIMESTAMP=`date +%F-%T`
BU_XSA_DIR=$PLNX_CONFIG_DIR/xsa/$TIMESTAMP

echo -e "\n"
echo "PLNX_PROJ_NAME: ${PLNX_PROJ_NAME}"
echo "WORK_DIR: ${WORK_DIR}"
echo "PLNX_PROJ_DIR: ${PLNX_PROJ_DIR}"
echo "PLNX_CONFIG_DIR: ${PLNX_CONFIG_DIR}"
echo "VIVADO_XSA_FILE: ${VIVADO_XSA_FILE}"
echo "TIMESTAMP: ${TIMESTAMP}"
echo "BU_XSA_DIR: ${BU_XSA_DIR}"
echo "Press Enter to continue..."
read

# Backup
# Copy XSA file from Vivado into the Petalinux Project
mkdir -p $BU_XSA_DIR
cp $VIVADO_XSA_FILE $BU_XSA_DIR

# Update the Petalinux Project with the new XSA
petalinux-config -p ${PLNX_PROJ_DIR} --get-hw-description=${PLNX_PROJ_DIR}/project-spec/configs/xsa/$TIMESTAMP --silentconfig
