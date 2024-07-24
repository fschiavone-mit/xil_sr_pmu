#!/bin/bash

# Create BOOT.BIN binary

PLNX_PROJ_NAME=sr_plnx
WORK_DIR=$(pwd)
PLNX_PROJ_DIR=${WORK_DIR}/${PLNX_PROJ_NAME}
IMG_DIR=${PLNX_PROJ_DIR}/images/linux

echo "PLNX_PROJ_DIR: ${PLNX_PROJ_DIR}"
echo "IMG_DIR: ${IMG_DIR}"

# Create BOOT.BIN
petalinux-package --boot \
  --project ${PLNX_PROJ_DIR} \
  --fsbl ${IMG_DIR}/zynqmp_fsbl.elf \
  --atf ${IMG_DIR}/bl31.elf \
  --pmufw ${IMG_DIR}/pmufw.elf \
  --u-boot ${IMG_DIR}/u-boot.elf \
  --boot-script ${IMG_DIR}/boot.scr \
  --boot-device sd \
  --format BIN \
  -o ${IMG_DIR}/BOOT.BIN \
  --force

# Create BOOT_FLASH.BIN
petalinux-package --boot \
  --project ${PLNX_PROJ_DIR} \
  --fsbl ${IMG_DIR}/zynqmp_fsbl.elf \
  --atf ${IMG_DIR}/bl31.elf \
  --pmufw ${IMG_DIR}/pmufw.elf \
  --u-boot ${IMG_DIR}/u-boot.elf \
  --boot-script ${IMG_DIR}/boot.scr \
  --fpga ${IMG_DIR}/system.bit \
  --boot-device flash \
  --format BIN \
  -o ${IMG_DIR}/BOOT_FLASH.BIN \
  --force
# FPGA no longer included alongside FSBL - to be loaded in U-boot or from filesystem
#  --fpga ${IMG_DIR}/system.bit \

#  --bootgen-extra-args "-log debug" \