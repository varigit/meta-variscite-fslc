#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run with super-user privileges" 
	exit 1
fi

product=mx6;

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

echo
echo "Flashing Yocto for ${full_product} on eMMC (${node})"

# Partition sizes in MiB
MEDIA=/opt/images/Yocto

umount ${mmm}* 2>/dev/null

function format_linux
{
	echo
	echo "Formating rootfs partition on eMMC"
	mkfs.ext4 ${node}${prefix}1 -L rootfs
	sync
}

function flash_linux
{
	echo
	echo "Installing rootfs on eMMC (this takes some time)"
	mkdir -p ${mmm}1
	mount ${node}${prefix}1 ${mmm}1
	tar xvpf ${MEDIA}/rootfs.tar.bz2 -C ${mmm}1/ 2>&1 |
	while read line; do
		x=$((x+1))
		echo -en "$x extracted\r"
	done
	echo
	echo "Syncing"
	sync
	umount ${node}${prefix}1
}

echo
echo "Deleting the current partitions"
for ((i=0; i<10; i++))
do
	if [ `ls ${node}${prefix}$i 2> /dev/null | grep -c ${node}${prefix}$i` -ne 0 ]; then
		dd if=/dev/zero of=${node}${prefix}$i bs=512 count=1024
	fi
done
sync

((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk ${node} &> /dev/null) || true
sync

dd if=/dev/zero of=${node} bs=512 count=1024
sync

# Get total card size
TOTAL_SIZE_KiB=`sfdisk -s ${node}`
TOTAL_SIZE_BYTES=$((TOTAL_SIZE_KiB * 1024))
BLOCK=`echo ${node} | cut -d "/" -f 3`
SECT_SIZE_BYTES=`cat /sys/block/${BLOCK}/queue/physical_block_size`
PART_SIZE=$(( (TOTAL_SIZE_BYTES / SECT_SIZE_BYTES) - 1 ))

echo
echo "Creating partition"
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
flash_linux
