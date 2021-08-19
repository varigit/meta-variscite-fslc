#!/bin/bash
# Meant to be called by install_yocto.sh
set -e

. /usr/bin/echos.sh

if [[ $EUID != 0 ]] ; then
	red_bold_echo "This script must be run with super-user privileges"
	exit 1
fi

swupdate=0

while getopts :b:u OPTION;
do
	case $OPTION in
		b)
			if [[ $OPTARG == dart ]] ; then
				is_dart=true
			fi
			;;
		u)
			swupdate=1
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

if [[ $swupdate == 1 ]] ; then
	bootpart=none
	rootfspart=1
	rootfs2part=2
	datapart=3

	DATA_SIZE=200
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

function create_swupdate_parts
{
	echo
	blue_underlined_bold_echo "Creating new partitions"
	TOTAL_SECTORS=`cat /sys/class/block/${block}/size`
	SECT_SIZE_BYTES=`cat /sys/block/${block}/queue/hw_sector_size`

	if [[ $is_dart == true ]] ; then
		BOOTLOAD_RESERVE_SIZE=4
	else
		BOOTLOAD_RESERVE_SIZE=0
	fi

	BOOTLOAD_RESERVE_SIZE_BYTES=$((BOOTLOAD_RESERVE_SIZE * 1024 * 1024))
	ROOTFS1_PART_START=$((BOOTLOAD_RESERVE_SIZE_BYTES / SECT_SIZE_BYTES))

	DATA_SIZE_BYTES=$((DATA_SIZE * 1024 * 1024))
	DATA_PART_SIZE=$((DATA_SIZE_BYTES / SECT_SIZE_BYTES))

	ROOTFS1_PART_SIZE=$((( TOTAL_SECTORS - ROOTFS1_PART_START - DATA_PART_SIZE ) / 2))
	ROOTFS2_PART_SIZE=$ROOTFS1_PART_SIZE

	ROOTFS2_PART_START=$((ROOTFS1_PART_START + ROOTFS1_PART_SIZE))
	DATA_PART_START=$((ROOTFS2_PART_START + ROOTFS2_PART_SIZE))

	ROOTFS1_PART_END=$((ROOTFS2_PART_START - 1))
	ROOTFS2_PART_END=$((DATA_PART_START - 1))

	if [[ $ROOTFS1_PART_START == 0 ]] ; then
		ROOTFS1_PART_START=""
	fi

	(echo n; echo p; echo $rootfspart;  echo $ROOTFS1_PART_START; echo $ROOTFS1_PART_END; \
	 echo n; echo p; echo $rootfs2part; echo $ROOTFS2_PART_START; echo $ROOTFS2_PART_END; \
	 echo n; echo p; echo $datapart;    echo $DATA_PART_START; echo; \
	 echo p; echo w) | fdisk -u $node > /dev/null

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
	blue_underlined_bold_echo "Formatting rootfs partition/s"
	if [[ $swupdate == 0 ]] ; then
		mkfs.ext4 ${node}${part}${rootfspart}  -L rootfs
	elif [[ $swupdate == 1 ]] ; then
		mkfs.ext4 ${node}${part}${rootfspart}  -L rootfs1
		mkfs.ext4 ${node}${part}${rootfs2part} -L rootfs2
		mkfs.ext4 ${node}${part}${datapart}    -L data
	fi
	sync; sleep 1
}

# $1 is the full path of the config file
set_fw_env_config_to_emmc()
{
	sed -i "/mtd/ s/^#*/#/" $1
	sed -i "s/#*\/dev\/mmcblk./\/dev\/${block}/" $1
}

set_fw_utils_to_emmc_on_sd_card()
{
	# Adjust u-boot-fw-utils for eMMC on the SD card
	if [[ `readlink /etc/u-boot-initial-env` != "u-boot-initial-env-sd" ]]; then
		ln -sf u-boot-initial-env-sd /etc/u-boot-initial-env
	fi

	if [[ -f /etc/fw_env.config ]]; then
		set_fw_env_config_to_emmc /etc/fw_env.config
	fi
}

set_fw_utils_to_emmc_on_emmc()
{
	# Adjust u-boot-fw-utils for eMMC on the installed rootfs
	rm -f ${mountdir_prefix}${rootfspart}/etc/u-boot-initial-env-*nand*
	if [[ -f ${mountdir_prefix}${rootfspart}/etc/u-boot-initial-env-sd ]]; then
		ln -sf u-boot-initial-env-sd ${mountdir_prefix}${rootfspart}/etc/u-boot-initial-env
	fi

	if [[ -f ${mountdir_prefix}${rootfspart}/etc/fw_env.config ]]; then
		set_fw_env_config_to_emmc ${mountdir_prefix}${rootfspart}/etc/fw_env.config
	fi
}

function install_bootloader
{
	echo
	blue_underlined_bold_echo "Installing booloader"
	dd if=${imagesdir}/SPL-sd of=${node} bs=1K seek=1; sync
	dd if=${imagesdir}/u-boot.img-sd of=${node} bs=1K seek=69; sync

	if [[ $swupdate == 1 ]] ; then
		echo
		echo "Setting U-Boot enviroment variables"
		set_fw_utils_to_emmc_on_sd_card
		fw_setenv mmcrootpart 1  2> /dev/null
		fw_setenv bootdir /boot
	fi
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
	printf "Extracting files"
	tar xpf ${imagesdir}/rootfs.tar.gz -C ${mountdir_prefix}${rootfspart} --checkpoint=.1200
	echo

	if [[ $is_dart == true ]] ; then
		set_fw_utils_to_emmc_on_emmc
	fi

	echo
	sync
	umount ${node}${part}${rootfspart}
}

stop_udev()
{
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl -q stop \
			systemd-udevd-kernel.socket \
			systemd-udevd-control.socket \
			systemd-udevd
	else
		/etc/init.d/udev stop
	fi
}

start_udev()
{
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl -q start \
			systemd-udevd-kernel.socket \
			systemd-udevd-control.socket \
			systemd-udevd
	else
		/etc/init.d/udev start
	fi
}

check_images

umount ${node}${part}*  2> /dev/null || true

stop_udev

delete_device
if [[ $swupdate == 1 ]] ; then
	create_swupdate_parts
else
	create_parts
fi
format_rootfs_part
install_rootfs

if [[ $is_dart == true ]] ; then
	install_bootloader
	if [[ $swupdate == 0 ]] ; then
		format_boot_part
		install_kernel
	fi
fi

start_udev

exit 0
