#!/bin/sh
# Installs Yocto to NAND/eMMC
set -e

. /usr/bin/echos.sh

MEDIA=/opt/images/Yocto
SPL_IMAGE=SPL-nand
UBOOT_IMAGE=u-boot.img-nand
KERNEL_IMAGE=uImage
KERNEL_DTB=""
ROOTFS_IMAGE=rootfs.ubi
ROOTFS_DEV=""


install_bootloader()
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	if [[ ! -f $MEDIA/$UBOOT_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$MEDIA/$UBOOT_IMAGE\" does not exist"
		exit 1
	fi

	if [[ ! -f $MEDIA/$SPL_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$MEDIA/$SPL_IMAGE\" does not exist"
		exit 1
	fi

	flash_erase /dev/mtd0 0 0 2> /dev/null
	kobs-ng init -x $MEDIA/$SPL_IMAGE --search_exponent=1 -v > /dev/null

	flash_erase /dev/mtd1 0 0 2> /dev/null
	nandwrite -p /dev/mtd1 $MEDIA/$UBOOT_IMAGE
}

install_kernel()
{
	if [[ ! -f $MEDIA/$KERNEL_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$MEDIA/$KERNEL_IMAGE\" does not exist"
		exit 1
	fi
	echo
	blue_underlined_bold_echo "Installing kernel"
	flash_erase /dev/mtd2 0 0 2> /dev/null
	nandwrite -p /dev/mtd2 $MEDIA/$KERNEL_IMAGE > /dev/null
	nandwrite -p /dev/mtd1 -s 0x1e0000 $MEDIA/$KERNEL_DTB > /dev/null
}

install_rootfs_to_nand()
{
	if [[ ! -f $MEDIA/$ROOTFS_IMAGE ]] ; then
		red_bold_echo "ERROR: \"$MEDIA/$ROOTFS_IMAGE\" does not exist"
		exit 1
	fi
	echo
	blue_underlined_bold_echo "Installing UBI rootfs"
	ubiformat /dev/mtd3 -f $MEDIA/$ROOTFS_IMAGE -y
}

install_rootfs()
{
	if [[ $ROOTFS_DEV != "emmc" ]] ; then
		install_rootfs_to_nand
	else
		/usr/bin/install_yocto_emmc.sh
		echo
		blue_underlined_bold_echo "Setting rootfs device to emmc in the U-Boot enviroment"
		fw_setenv rootfs_device emmc  2> /dev/null
		echo Done.
	fi
}

usage()
{
	echo
	echo "This script installs Yocto on the SOM's internal storage device/s"
	echo
	echo " Usage: $0 OPTIONS"
	echo
	echo " OPTIONS:"
	echo " -b <mx6cb|scb|dart>	carrier Board model (MX6CustomBoard/SOLOCustomBoard/DART-MX6) - mandartory parameter."
	echo " -t <cap|res>		Touchscreen model (capacitive/resistive) - mandatory in case of MX6CustomBoard; ignored otherwise."
	echo " -r <nand|emmc>		Rootfs device (NAND/eMMC) - mandatory in case of MX6CustomBoard/SOLOCustomBoard; ignored in case of DART-MX6."
	echo
}

finish()
{
	sync
	echo
	blue_bold_echo "Yocto installed successfully"
	exit 0
}


blue_underlined_bold_echo "*** Variscite MX6 Yocto eMMC/NAND Recovery ***"
echo

while getopts :b:t:r: OPTION;
do
	case $OPTION in
	b)
		BOARD=$OPTARG
		;;
	t)
		TOUCHSCREEN=$OPTARG
		;;
	r)
		ROOTFS_DEV=$OPTARG
		;;
	*)
		usage
		exit 1
		;;
	esac
done

STR=""

if [[ $BOARD == "mx6cb" ]] ; then
	STR="MX6CustomBoard"
elif [[ $BOARD == "scb" ]] ; then
	STR="SOLOCustomBoard"
elif [[ $BOARD == "dart" ]] ; then
	STR="DART-MX6"
else
	usage
	exit 1
fi

printf "Carrier board: "
blue_bold_echo $STR

if [[ $BOARD == "dart" ]] ; then
	/usr/bin/install_yocto_emmc.sh -b dart
	finish
fi

if [[ $BOARD == "mx6cb" ]] ; then
	if [[ $TOUCHSCREEN == "cap" ]] ; then
		STR="Capacitive"
	elif [[ $TOUCHSCREEN == "res" ]] ; then
		STR="Resistive"
	else
		usage
		exit 1
	fi
	printf "Touchscreen model: "
	blue_bold_echo $STR
fi

if [[ $ROOTFS_DEV == "nand" ]] ; then
	STR="NAND"
elif [[ $ROOTFS_DEV == "emmc" ]] ; then
	STR="eMMC"
else
	usage
	exit 1
fi

printf "Installing rootfs to: "
blue_bold_echo $STR


CPUS=`cat /proc/cpuinfo | grep -c processor`

if [[ $CPUS == 1 ]] || [[ $CPUS == 2 ]] ; then
	if [[ `dmesg | grep -c SOM-SOLO` == 1 ]] ; then
		if [[ "$BOARD" == "scb" ]] ; then
			KERNEL_DTB=imx6dl-var-som-solo-vsc.dtb
		else
			KERNEL_DTB=imx6dl-var-som-solo-$TOUCHSCREEN.dtb
		fi
	else
		if [[ $CPUS == 1 ]] || [[ `dmesg | grep -c i.MX6DL` == 1 ]] ; then
			# iMX6 Solo/DualLite
			if [[ $BOARD == "scb" ]] ; then
				KERNEL_DTB=imx6dl-var-som-vsc.dtb
			else
				KERNEL_DTB=imx6dl-var-som-$TOUCHSCREEN.dtb
			fi
		else
			# iMX6 Dual
			CPUS=4
		fi
	fi
fi

#iMX6 Dual/Quad
if [[ $CPUS == 4 ]] ; then
	if [[ `cat /sys/devices/soc0/soc_id` == "i.MX6QP" ]] ; then
		QUADTYPE="imx6qp"
	else
		QUADTYPE="imx6q"
	fi
	if [[ $BOARD == "scb" ]] ; then
		KERNEL_DTB=$QUADTYPE-var-som-vsc.dtb
	else
		KERNEL_DTB=$QUADTYPE-var-som-$TOUCHSCREEN.dtb
	fi
fi

printf "Installing Device Tree file: "
blue_bold_echo $KERNEL_DTB

install_bootloader
install_kernel
install_rootfs

finish
