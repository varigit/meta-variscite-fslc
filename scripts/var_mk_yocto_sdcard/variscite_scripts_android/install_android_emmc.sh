#!/bin/bash
# Meant to be called by install_android.sh
# Added GPT feature for Android 7.1.2_r9
set -e

. /usr/bin/echos.sh

help() {

	bn=`basename $0`
	echo " usage $bn <option> device_node"
	echo
	echo " options:"
	echo " -h			displays this help message"
	echo " -f soc_name		flash android image."
}

# Parse command line
moreoptions=1
node="na"
soc_name=""
cal_only=0

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
	    -f) soc_name=$2; shift;;
	    *)  moreoptions=0; block=$1; is_dart=$2 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 2 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

systemimage_file="system_raw.img"
bootimage_file="boot-${soc_name}.img"
recoveryimage_file="recovery-${soc_name}.img"
partition_file="partition-table.img"
imagesdir=/opt/images/Android
node=/dev/${block}
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

function check_images
{
	if [[ ! -b $node ]] ; then
		red_bold_echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi
	if [[ ! -f ${imagesdir}/${partition_file} ]] ; then
			red_bold_echo "ERROR: Partition image does not exist"
			exit 1
	fi

	if [[ $is_dart == true ]] ; then
		if [[ ! -f ${imagesdir}/SPL-mmc ]] ; then
			red_bold_echo "ERROR: SPL image does not exist"
			exit 1
		fi

		if [[ ! -f ${imagesdir}/u-boot-var-imx6-mmc.img ]] ; then
			red_bold_echo "ERROR: U-Boot image does not exist"
			exit 1
		fi
	else
		if [[ ! -f ${imagesdir}/SPL-nand ]] ; then
			red_bold_echo "ERROR: SPL image does not exist"
			exit 1
		fi

		if [[ ! -f ${imagesdir}/u-boot-var-imx6-nand.img ]] ; then
			red_bold_echo "ERROR: U-Boot image does not exist"
			exit 1
		fi
	fi

	if [[ ! -f ${imagesdir}/${bootimage_file} ]] ; then
		red_bold_echo "ERROR: boot image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${recoveryimage_file} ]] ; then
		red_bold_echo "ERROR: recovery image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${systemimage_file} ]] ; then
		red_bold_echo "ERROR: system image does not exist"
		exit 1
	fi
}

function delete_device
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"
	for ((i=0; i<=12; i++))
	do
		if [[ -e ${node}${part}${i} ]] ; then
			dd if=/dev/zero of=${node}${part}${i} bs=1024 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	dd if=/dev/zero of=$node bs=1M count=4
	fdisk -u -l ${node}
	sync; sleep 1
}

function create_parts
{
	echo
	blue_underlined_bold_echo "Creating Android partitions"
	dd if=${imagesdir}/${partition_file} of=${node} conv=fsync
}

function install_bootloader
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	fdisk -u -l $node
	if [[ $is_dart == true ]] ; then
		dd if=${imagesdir}/SPL-mmc of=$node bs=1k seek=1 conv=fsync ; sync

		dd if=${imagesdir}/u-boot-var-imx6-mmc.img of=$node bs=1k seek=69 conv=fsync; sync
	else
		flash_erase /dev/mtd0 0 0 2> /dev/null
		kobs-ng init -x ${imagesdir}/SPL-nand --search_exponent=1 -v > /dev/null

		flash_erase /dev/mtd1 0 0 2> /dev/null
		nandwrite -p /dev/mtd1 ${imagesdir}/u-boot-var-imx6-nand.img

		sync
	fi
}

function format_android
{
	fdisk -u -l $node
	umount ${node}${part}*  2> /dev/null || true
	echo
	blue_underlined_bold_echo "Formating Android partitions"
	mkfs.ext4 -F ${node}${part}10 -Ldata
	mkfs.ext4 -F ${node}${part}3 -Lsystem
	mkfs.ext4 -F ${node}${part}4 -Lcache
	mkfs.ext4 -F ${node}${part}5 -Ldevice
}

function install_android
{
	echo
	blue_underlined_bold_echo "Installing Android boot image: $bootimage_file"
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}1
	sync

	echo
	blue_underlined_bold_echo "Installing Android recovery image: $recoveryimage_file"
	dd if=${imagesdir}/${recoveryimage_file} of=${node}${part}2
	sync

	echo
	blue_underlined_bold_echo "Installing Android system image: $systemimage_file"
	dd if=${imagesdir}/${systemimage_file} of=${node}${part}3
	sync; sleep 1
}

check_images

umount ${node}${part}*  2> /dev/null || true

/etc/init.d/udev stop #Stop Udev for block devices while partitioning in progress
delete_device
create_parts
sleep 3
for i in `cat /proc/mounts | grep "${node}" | awk '{print $2}'`; do umount $i; done
hdparm -z ${node}

# backup the GPT table to last LBA.
echo -e 'r\ne\nY\nw\nY\nY' |  gdisk ${node}

install_bootloader
format_android
install_android

/etc/init.d/udev start #Start Udev back before exit
exit 0
