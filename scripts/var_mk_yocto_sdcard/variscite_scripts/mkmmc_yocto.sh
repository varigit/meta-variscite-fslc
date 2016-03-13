#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run with super-user privileges" 
	exit 1
fi

product=mx6;

echo $product
full_product=var_som_${product}

if [ `dmesg | grep VAR-DART | wc -l` = 1 ] ; then
	node=/dev/mmcblk2
	mmm=/run/media/mmcblk2p
else
	node=/dev/mmcblk1
	mmm=/run/media/mmcblk1p
fi
prefix=p

if [ ! -b ${node} ]; then
	echo "ERROR: \"${node}\" is not block device"
	exit
fi

echo "Creating Android SD-card on ${node} for product ${full_product}"

# Partition sizes in MiB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=8
SYSTEM_ROM_SIZE=512
CACHE_SIZE=512
RECOVERY_ROM_SIZE=8
VENDER_SIZE=8
MISC_SIZE=8
MEDIA=/opt/images/Yocto

umount ${mmm}1 2>/dev/null
umount ${mmm}2 2>/dev/null
umount ${mmm}3 2>/dev/null
umount ${mmm}4 2>/dev/null
umount ${mmm}5 2>/dev/null
umount ${mmm}6 2>/dev/null
umount ${mmm}7 2>/dev/null
umount ${mmm}8 2>/dev/null
umount ${mmm}9 2>/dev/null


function format_linux
{
	echo "Formating rootfs partition on eMMC"
	mkfs.ext4 ${node}${prefix}1 -L rootfs
}

function flash_linux
{
	echo "Installing rootfs on eMMC (this takes some time)"
	mkdir ${mmm}1
	mount ${node}${prefix}1  ${mmm}1
	tar xvpf ${MEDIA}/rootfs.tar.bz2 -C ${mmm}1/ 2>&1 |
	while read line; do
		x=$((x+1))
		echo -en "$x extracted\r"
	done
}

# Destroy the partition table
dd if=/dev/zero of=${node} bs=512 count=1
sync

# Get total card size
TOTAL_SIZE_KiB=`sfdisk -s ${node}`
TOTAL_SIZE_BYTES=$((TOTAL_SIZE * 1024))
SECT_SIZE_BYTES=`fdisk -l ${node} 2>> /dev/null | grep 'Sector size' | cut -d " " -f 7`
PART_SIZE=$((TOTAL_SIZE_BYTES / SECT_SIZE_BYTES))

# Create the partition table
sfdisk --force -uS ${node} << EOF
,${PART_SIZE},83
EOF
if [ "$?" = "0" ]; then
	sync
	sleep 4
else
	echo -e "\e[31msfdisk error #1! Partition is locked\e[0m"
	echo -e "\e[31mplease reboot to unlock and try again\e[0m"
	echo "==============================================="
	echo " "
	exit 1
fi

format_linux
sync
flash_linux

echo "Syncing"
sync
umount ${mmm}1
echo "Done"
exit 0
