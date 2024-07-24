#!/bin/bash

# Mount SD, backup files, format SD, copy over new binaries.

PLNX_PROJ_NAME=sr_plnx
WORK_DIR=$(pwd)
PLNX_PROJ_DIR=${WORK_DIR}/${PLNX_PROJ_NAME}
TIMESTAMP=`date +%F-%T`
BOOT_PART=sda1
ROOT_PART=sda2
echo "PLNX_PROJ_DIR: ${PLNX_PROJ_DIR}"
echo "TIMESTAMP: ${TIMESTAMP}"
echo "ls /dev/sd*"
echo "BOOT_PARTITION: ${BOOT_PART}"
echo "ROOT_PARTITION: ${ROOT_PART}"
echo -e "\n"

echo "Backup SD Card"
sudo mount /dev/sda1 /mnt/sd_card_boot/
sudo mount /dev/sda2 /mnt/sd_card_root/
mkdir -p ${PLNX_PROJ_DIR}/images/linux/backup_sd/${TIMESTAMP}/boot
mkdir -p ${PLNX_PROJ_DIR}/images/linux/backup_sd/${TIMESTAMP}/root
cp -r /mnt/sd_card_boot/* ${PLNX_PROJ_DIR}/images/linux/backup_sd/${TIMESTAMP}/boot/
cp -r /mnt/sd_card_root/* ${PLNX_PROJ_DIR}/images/linux/backup_sd/${TIMESTAMP}/root/

echo -e "\n"
echo "Wipe root partition"
echo "Press Enter to continue..."
read
sudo dd if=/dev/zero of=/dev/sda2 bs=4096 status=progress

echo -e "\n"
echo "Extract rootfs"
echo "Press Enter to continue..."
read
sudo dd if=${PLNX_PROJ_DIR}/images/linux/rootfs.ext4 of=/dev/sda2  

echo -e "\n"
echo "Update boot partition"
echo "Press Enter to continue..."
read
sudo cp ${PLNX_PROJ_DIR}/images/linux/image.ub /mnt/sd_card_boot/
sudo cp ${PLNX_PROJ_DIR}/images/linux/boot.scr /mnt/sd_card_boot/
sudo cp ${PLNX_PROJ_DIR}/images/linux/BOOT.BIN /mnt/sd_card_boot/

echo -e "\n"
echo "Unmount SD card for save removal"
echo "Press Enter to continue..."
read
sudo umount /mnt/sd_card_boot 
sudo umount /mnt/sd_card_root 

echo "Done"
