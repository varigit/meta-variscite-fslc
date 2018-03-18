#!/bin/bash

# Installs Yocto to NAND/eMMC
set -e

. /usr/bin/echos.sh

IMGS_PATH=/opt/images/Yocto
KERNEL_IMAGE=zImage
KERNEL_DTB=""
STORAGE_DEV=""

if [[ $EUID != 0 ]] ; then
	red_bold_echo "This script must be run with super-user privileges"
	exit 1
fi

check_images()
{
	if [[ ! -f $IMGS_PATH/$SPL_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$IMGS_PATH/$SPL_IMAGE\" does not exist"
		exit 1
	fi

	if [[ ! -f $IMGS_PATH/$UBOOT_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$IMGS_PATH/$UBOOT_IMAGE\" does not exist"
		exit 1
	fi

	if [[ ! -f $IMGS_PATH/$KERNEL_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$IMGS_PATH/$KERNEL_IMAGE\" does not exist"
		exit 1
	fi

	if [[ $STORAGE_DEV == "nand" && ! -f $IMGS_PATH/$KERNEL_DTB ]] ; then
		red_bold_echo "ERROR: \"$IMGS_PATH/$KERNEL_DTB\" does not exist"
		exit 1
	fi

	if [[ ! -f $IMGS_PATH/$ROOTFS_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$IMGS_PATH/$ROOTFS_IMAGE\" does not exist"
		exit 1
	fi
}

install_bootloader_to_nand()
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	flash_erase /dev/mtd0 0 0 2> /dev/null
	kobs-ng init -x $IMGS_PATH/$SPL_IMAGE --search_exponent=1 -v > /dev/null

	flash_erase /dev/mtd1 0 0 2> /dev/null
	nandwrite -p /dev/mtd1 $IMGS_PATH/$UBOOT_IMAGE

	flash_erase /dev/mtd2 0 0 2> /dev/null
	sync
}

install_kernel_to_nand()
{
	echo
	blue_underlined_bold_echo "Installing kernel"

	flash_erase /dev/mtd3 0 0 2> /dev/null
	nandwrite -p /dev/mtd3 $IMGS_PATH/$KERNEL_IMAGE > /dev/null
	nandwrite -p /dev/mtd3 -s 0x7e0000 $IMGS_PATH/$KERNEL_DTB > /dev/null
	sync
}

install_rootfs_to_nand()
{
	echo
	blue_underlined_bold_echo "Installing UBI rootfs"

	ubiformat /dev/mtd4 -f $IMGS_PATH/$ROOTFS_IMAGE -y
	sync
}

delete_emmc()
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

create_emmc_parts()
{
	echo
	blue_underlined_bold_echo "Creating new partitions"

	SECT_SIZE_BYTES=`cat /sys/block/${block}/queue/hw_sector_size`
	PART1_FIRST_SECT=`expr 4 \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	PART2_FIRST_SECT=`expr $((4 + 8)) \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	PART1_LAST_SECT=`expr $PART2_FIRST_SECT - 1`

	(echo n; echo p; echo $bootpart; echo $PART1_FIRST_SECT; echo $PART1_LAST_SECT; echo t; echo c; \
	 echo n; echo p; echo $rootfspart; echo $PART2_FIRST_SECT; echo; \
	 echo p; echo w) | fdisk -u $node > /dev/null

	sync; sleep 1
	fdisk -u -l $node
}

format_emmc_parts()
{
	echo
	blue_underlined_bold_echo "Formatting partitions"

	mkfs.vfat ${node}${part}${bootpart} -n ${FAT_VOLNAME}
	mkfs.ext4 ${node}${part}${rootfspart} -L rootfs
	sync; sleep 1
}

install_bootloader_to_emmc()
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	dd if=${IMGS_PATH}/${SPL_IMAGE} of=${node} bs=1K seek=1; sync
	dd if=${IMGS_PATH}/${UBOOT_IMAGE} of=${node} bs=1K seek=69; sync
}

install_kernel_to_emmc()
{
	echo
	blue_underlined_bold_echo "Installing kernel to BOOT partition"

	mkdir -p ${mountdir_prefix}${bootpart}
	mount -t vfat ${node}${part}${bootpart}		${mountdir_prefix}${bootpart}
	cd ${IMGS_PATH}
	cp -v ${KERNEL_DTBS}	${mountdir_prefix}${bootpart}
	cp -v ${KERNEL_IMAGE}	${mountdir_prefix}${bootpart}
	cd - >/dev/null
	sync
	umount ${node}${part}${bootpart}
}

install_rootfs_to_emmc()
{
	echo
	blue_underlined_bold_echo "Installing rootfs"

	mkdir -p ${mountdir_prefix}${rootfspart}
	mount ${node}${part}${rootfspart} ${mountdir_prefix}${rootfspart}
	tar xvpf ${IMGS_PATH}/${ROOTFS_IMAGE} -C ${mountdir_prefix}${rootfspart} |
	while read line; do
		x=$((x+1))
		echo -en "$x files extracted\r"
	done
	echo
	sync
	umount ${node}${part}${rootfspart}
}

usage()
{
	echo
	echo "This script installs Yocto on the SOM's internal storage device"
	echo
	echo " Usage: $0 OPTIONS"
	echo
	echo " OPTIONS:"
	echo " -b <mx6ul|mx6ul5g|mx6ull|mx6ull5g|mx7>	Board model (DART-6UL/DART-6UL-5G/DART-6ULL/DART-6ULL-5G/VAR-SOM-MX7) - mandatory parameter."
	echo " -r <nand|emmc>		storage device (NAND flash/eMMC) - mandatory parameter."
	echo " -v <wifi|sd>		DART-6UL Variant (WiFi/SD card) - mandatory in case of DART-6UL with NAND flash; ignored otherwise."
	echo " -m			optional Cortex-M4 support for VAR-SOM-MX7 with NAND flash; ignored otherwise."
	echo
}

finish()
{
	echo
	blue_bold_echo "Yocto installed successfully"
	exit 0
}


blue_underlined_bold_echo "*** Variscite MX6UL/MX6ULL/MX7 Yocto eMMC/NAND Recovery ***"
echo

VARSOMMX7_VARIANT=""
while getopts :b:r:v:m OPTION;
do
	case $OPTION in
	b)
		BOARD=$OPTARG
		;;
	r)
		STORAGE_DEV=$OPTARG
		;;
	v)
		DART6UL_VARIANT=$OPTARG
		;;
	m)
		VARSOMMX7_VARIANT=-m4
		;;
	*)
		usage
		exit 1
		;;
	esac
done

STR=""

if [[ $BOARD == "mx6ul" ]] ; then
	STR="DART-6UL"
elif [[ $BOARD == "mx6ull" ]] ; then
	STR="DART-6ULL"
elif [[ $BOARD == "mx6ul5g" ]] ; then
	STR="DART-6UL-5G"
elif [[ $BOARD == "mx6ull5g" ]] ; then
	STR="DART-6ULL-5G"
elif [[ $BOARD == "mx7" ]] ; then
	STR="VAR-SOM-MX7"
else
	usage
	exit 1
fi

printf "Board: "
blue_bold_echo $STR

if [[ $BOARD == mx6ul* ]] ; then
	if [[ $STORAGE_DEV == "nand" ]] ; then
		if [[ $DART6UL_VARIANT == "wifi" ]] ; then
			STR="WiFi (no SD card)"
		elif [[ $DART6UL_VARIANT == "sd" ]] ; then
			STR="SD card (no WiFi)"
		else
			usage
			exit 1
		fi
		printf "With:  "
		blue_bold_echo "$STR"
	fi
fi

if [[ $STORAGE_DEV == "nand" ]] ; then
	STR="NAND"
	ROOTFS_IMAGE=rootfs.ubi
elif [[ $STORAGE_DEV == "emmc" ]] ; then
	STR="eMMC"
	ROOTFS_IMAGE=rootfs.tar.bz2
else
	usage
	exit 1
fi

printf "Installing to internal storage device: "
blue_bold_echo $STR


if [[ $STORAGE_DEV == "nand" ]] ; then
	SPL_IMAGE=SPL-nand
	UBOOT_IMAGE=u-boot.img-nand

	if [[ $BOARD == mx6ul* ]] ; then
		if [[ $BOARD == "mx6ul" ]] ; then
			if [[ $DART6UL_VARIANT == "wifi" ]] ; then
				KERNEL_DTB=imx6ul-var-dart-nand_wifi.dtb
			elif [[ $DART6UL_VARIANT == "sd" ]] ; then
				KERNEL_DTB=imx6ul-var-dart-sd_nand.dtb
			fi
		elif [[ $BOARD == "mx6ull" ]] ; then
			if [[ $DART6UL_VARIANT == "wifi" ]] ; then
				KERNEL_DTB=imx6ull-var-dart-nand_wifi.dtb
			elif [[ $DART6UL_VARIANT == "sd" ]] ; then
				KERNEL_DTB=imx6ull-var-dart-sd_nand.dtb
			fi
		elif [[ $BOARD == "mx6ul5g" ]] ; then
			if [[ $DART6UL_VARIANT == "wifi" ]] ; then
				KERNEL_DTB=imx6ul-var-dart-5g-nand_wifi.dtb
			elif [[ $DART6UL_VARIANT == "sd" ]] ; then
				KERNEL_DTB=imx6ul-var-dart-sd_nand.dtb
			fi
		elif [[ $BOARD == "mx6ull5g" ]] ; then
			if [[ $DART6UL_VARIANT == "wifi" ]] ; then
				KERNEL_DTB=imx6ull-var-dart-5g-nand_wifi.dtb
			elif [[ $DART6UL_VARIANT == "sd" ]] ; then
				KERNEL_DTB=imx6ull-var-dart-sd_nand.dtb
			fi
		fi
	elif [[ $BOARD == "mx7" ]] ; then
		KERNEL_DTB=imx7d-var-som-nand${VARSOMMX7_VARIANT}.dtb
	fi

	printf "Installing Device Tree file: "
	blue_bold_echo $KERNEL_DTB

	if [[ ! -e /dev/mtd0 ]] ; then
		red_bold_echo "ERROR: Can't find NAND flash device."
		red_bold_echo "Please verify you are using the correct options for your SOM."
		exit 1
	fi

	check_images
	install_bootloader_to_nand
	install_kernel_to_nand
	install_rootfs_to_nand
elif [[ $STORAGE_DEV == "emmc" ]] ; then
	SPL_IMAGE=SPL-sd
	UBOOT_IMAGE=u-boot.img-sd

	if [[ $BOARD == mx6ul* ]] ; then
		block=mmcblk1
		if [[ $BOARD == "mx6ul" || $BOARD == "mx6ul5g" ]] ; then
			KERNEL_DTBS="imx6ul-var-dart-emmc_wifi.dtb
				     imx6ul-var-dart-5g-emmc_wifi.dtb
				     imx6ul-var-dart-sd_emmc.dtb"
			FAT_VOLNAME=BOOT-VAR6UL
		elif [[ $BOARD == "mx6ull" || $BOARD == "mx6ull5g" ]] ; then
			KERNEL_DTBS="imx6ull-var-dart-emmc_wifi.dtb
				     imx6ull-var-dart-5g-emmc_wifi.dtb
				     imx6ull-var-dart-sd_emmc.dtb"
			FAT_VOLNAME=BOOT-VAR6ULL
		fi
	elif [[ $BOARD == "mx7" ]] ; then
		block=mmcblk2
		KERNEL_DTBS=imx7d-var-som-emmc*.dtb
		FAT_VOLNAME=BOOT-VARMX7
	fi
	node=/dev/${block}
	if [[ ! -b $node ]] ; then
		red_bold_echo "ERROR: Can't find eMMC device ($node)."
		red_bold_echo "Please verify you are using the correct options for your SOM."
		exit 1
	fi
	part=p
	mountdir_prefix=/run/media/${block}${part}
	bootpart=1
	rootfspart=2

	check_images
	umount ${node}${part}*  2> /dev/null || true
	delete_emmc
	create_emmc_parts
	format_emmc_parts
	install_bootloader_to_emmc
	install_kernel_to_emmc
	install_rootfs_to_emmc
fi

finish
