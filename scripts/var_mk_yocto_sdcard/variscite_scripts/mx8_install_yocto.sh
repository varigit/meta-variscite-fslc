#!/bin/bash -e

. /usr/bin/echos.sh

IMGS_PATH=/opt/images/Yocto
KERNEL_IMAGE=Image.gz
UBOOT_IMAGE=imx-boot-sd.bin
ROOTFS_IMAGE=rootfs.tar.gz
BOARD=imx8m-var-dart
BOOTLOADER_RESERVED_SIZE=8
BOOTLOADER_OFFSET=33
DISPLAY=dcss-lvds

PART=p
BLOCK=mmcblk0
NODE=/dev/${BLOCK}
ROOTFSPART=1
BOOTDIR=/boot
MOUNTDIR=/run/media/${BLOCK}${PART}${ROOTFSPART}
			
check_images()
{
	if [[ ! -f $IMGS_PATH/$UBOOT_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$IMGS_PATH/$UBOOT_IMAGE\" does not exist"
		exit 1
	fi

	if [[ ! -f $IMGS_PATH/$ROOTFS_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$IMGS_PATH/$ROOTFS_IMAGE\" does not exist"
		exit 1
	fi
}

delete_emmc()
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"

	umount ${NODE}${PART}* 2>/dev/null || true

	for ((i=0; i<=15; i++)); do
		if [[ -e ${NODE}${PART}${i} ]]; then
			dd if=/dev/zero of=${NODE}${PART}${i} bs=1M count=1 2>/dev/null || true
		fi
	done
	sync

	dd if=/dev/zero of=$NODE bs=1M count=${BOOTLOADER_RESERVED_SIZE}

	sync; sleep 1
}

create_emmc_parts()
{
	echo
	blue_underlined_bold_echo "Creating new partitions"

	SECT_SIZE_BYTES=`cat /sys/block/${BLOCK}/queue/hw_sector_size`
	PART1_FIRST_SECT=$(($BOOTLOADER_RESERVED_SIZE * 1024 * 1024 / $SECT_SIZE_BYTES))

	(echo n; echo p; echo $ROOTFSPART; echo $PART1_FIRST_SECT; echo; \
	 echo p; echo w) | fdisk -u $NODE > /dev/null

	sync; sleep 1
	fdisk -u -l $NODE
}

format_emmc_parts()
{
	echo
	blue_underlined_bold_echo "Formatting partitions"

	mkfs.ext4 ${NODE}${PART}${ROOTFSPART} -L rootfs

	sync; sleep 1
}

install_bootloader_to_emmc()
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	dd if=${IMGS_PATH}/${UBOOT_IMAGE} of=${NODE} bs=1K seek=${BOOTLOADER_OFFSET}
	sync
}

install_rootfs_to_emmc()
{
	echo
	blue_underlined_bold_echo "Installing rootfs"

	mkdir -p ${MOUNTDIR}
	mount ${NODE}${PART}${ROOTFSPART} ${MOUNTDIR}

	printf "Extracting files"
	tar --warning=no-timestamp -xpf ${IMGS_PATH}/${ROOTFS_IMAGE} -C ${MOUNTDIR} --checkpoint=.1200

	# Create DTB symlink
	(cd ${MOUNTDIR}/${BOOTDIR}; ln -fs ${BOARD}-emmc-wifi-${DISPLAY}.dtb ${BOARD}.dtb)

	# Adjust u-boot-fw-utils for eMMC on the installed rootfs
	sed -i "s/\/dev\/mmcblk./\/dev\/${BLOCK}/" ${MOUNTDIR}/etc/fw_env.config

	# Install blacklist.conf
	cp ${MOUNTDIR}/etc/wifi/blacklist.conf ${MOUNTDIR}/etc/modprobe.d

	echo
	sync

	umount ${MOUNTDIR}
}

usage()
{
	echo
	echo "This script installs Yocto on the SOM's internal storage device"
	echo
	echo " Usage: $(basename $0) <option>"
	echo
	echo " options:"
	echo " -h 					show help message"
	echo " -d <hdmi|hdmi-4k|dcss-lvds|lcdif-lvds>	set display type, default is dcss-lvds"
	echo
}

finish()
{
	echo
	blue_bold_echo "Yocto installed successfully"
	exit 0
}

if [[ $EUID != 0 ]] ; then
	red_bold_echo "This script must be run with super-user privileges"
	exit 1
fi

blue_underlined_bold_echo "*** Variscite MX8M Yocto eMMC Recovery ***"
echo

while getopts d:h OPTION;
do
	case $OPTION in
	d)
		DISPLAY=$OPTARG
		;;
	h)
		usage
		exit 0
		;;		
	*)
		usage
		exit 1
		;;
	esac
done

if [[ $DISPLAY != "hdmi" && $DISPLAY != "hdmi-4k" && \
      $DISPLAY != "dcss-lvds" && $DISPLAY != "lcdif-lvds" ]]; then
	echo "Invalid display, should be hdmi, hdmi-4k, dcss-lvds or lcdif-lvds"
	exit 1
fi

printf "Board: "
blue_bold_echo $BOARD

printf "Installing to internal storage device: "
blue_bold_echo eMMC

if [[ ! -b $NODE ]] ; then
	red_bold_echo "ERROR: Can't find eMMC device ($NODE)."
	red_bold_echo "Please verify you are using the correct options for your SOM."
	exit 1
fi
	
check_images
delete_emmc
create_emmc_parts
format_emmc_parts
install_bootloader_to_emmc
install_rootfs_to_emmc
finish

