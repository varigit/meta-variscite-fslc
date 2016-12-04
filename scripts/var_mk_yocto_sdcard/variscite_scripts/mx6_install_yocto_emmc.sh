#!/bin/bash
# Meant to be called by install_emmc.sh
set -e

. /usr/bin/echos.sh

if [[ $EUID != 0 ]] ; then
	red_bold_echo "This script must be run with super-user privileges"
	exit 1
fi

while getopts :b: OPTION;
do
	case $OPTION in
		b)
			if [[ $OPTARG == dart ]] ; then
				is_dart=true
			fi
			;;
	esac
done

if [[ $is_dart == true ]] ; then
	block=mmcblk2
	bootpart=1
	rootfspart=2
else
	block=mmcblk0
	bootpart=none
	rootfspart=1
fi

node=/dev/${block}
part=p
mountdir_prefix=/run/media/${block}${part}
imagesdir=/opt/images/Yocto

function check_images
{
	if [[ ! -b $node ]] ; then
		red_bold_echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi

	if [[ $is_dart == true ]] ; then
		if [[ ! -f ${imagesdir}/SPL-sd ]] ; then
			red_bold_echo "ERROR: SPL-sd does not exist"
			exit 1
		fi
		if [[ ! -f ${imagesdir}/u-boot.img-sd ]] ; then
			red_bold_echo "ERROR: u-boot.img-sd does not exist"
			exit 1
		fi
	fi
}

function delete_device
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"
	for ((i=0; i<=10; i++))
	do
		if [[ -e ${node}${part}${i} ]] ; then
			dd if=/dev/zero of=${node}${part}${i} bs=1024 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	dd if=/dev/zero of=$node bs=1M count=4
	sync; sleep 1
}

function create_parts
{
	echo
	blue_underlined_bold_echo "Creating new partitions"
	if [[ $is_dart == true ]] ; then
		SECT_SIZE_BYTES=`cat /sys/block/${block}/queue/hw_sector_size`
		PART1_FIRST_SECT=`expr 4 \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
		PART2_FIRST_SECT=`expr $((4 + 8)) \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
		PART1_LAST_SECT=`expr $PART2_FIRST_SECT - 1`

		(echo n; echo p; echo $bootpart; echo $PART1_FIRST_SECT; echo $PART1_LAST_SECT; echo t; echo c; \
		 echo n; echo p; echo $rootfspart; echo $PART2_FIRST_SECT; echo; \
		 echo p; echo w) | fdisk -u $node > /dev/null
	else
		(echo n; echo p; echo $rootfspart; echo; echo; echo p; echo w) | fdisk -u $node > /dev/null
	fi
	sync; sleep 1
	fdisk -u -l $node
}

function format_boot_part
{
	echo
	blue_underlined_bold_echo "Formatting BOOT partition"
	mkfs.vfat ${node}${part}${bootpart} -n BOOT-VARSOM
	sync; sleep 1
}

function format_rootfs_part
{
	echo
	blue_underlined_bold_echo "Formatting rootfs partition"
	mkfs.ext4 ${node}${part}${rootfspart} -L rootfs
	sync; sleep 1
}

function install_bootloader
{
	echo
	blue_underlined_bold_echo "Installing booloader"
	sudo dd if=${imagesdir}/SPL-sd of=${node} bs=1K seek=1; sync
	sudo dd if=${imagesdir}/u-boot.img-sd of=${node} bs=1K seek=69; sync
}

function install_kernel
{
	echo
	blue_underlined_bold_echo "Installing kernel to BOOT partition"
	mkdir -p ${mountdir_prefix}${bootpart}
	mount -t vfat ${node}${part}${bootpart}		${mountdir_prefix}${bootpart}
	cp -v ${imagesdir}/imx6q-var-dart.dtb		${mountdir_prefix}${bootpart}
	cp -v ${imagesdir}/uImage			${mountdir_prefix}${bootpart}
	sync
	umount ${node}${part}${bootpart}
}

function install_rootfs
{
	echo
	blue_underlined_bold_echo "Installing rootfs"
	mkdir -p ${mountdir_prefix}${rootfspart}
	mount ${node}${part}${rootfspart} ${mountdir_prefix}${rootfspart}
	tar xvpf ${imagesdir}/rootfs.tar.bz2 -C ${mountdir_prefix}${rootfspart} |
	while read line; do
		x=$((x+1))
		echo -en "$x files extracted\r"
	done
	echo
	sync
	umount ${node}${part}${rootfspart}
}

check_images

umount ${node}${part}*  2> /dev/null || true

delete_device
create_parts
format_rootfs_part
install_rootfs

if [[ $is_dart == true ]] ; then
	format_boot_part
	install_bootloader
	install_kernel
fi

exit 0
