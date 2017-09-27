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

set_fw_utils_to_nand()
{
	# Adjust u-boot-fw-utils for NAND flash on the SD card
	if [[ `readlink /sbin/fw_printenv` != "/sbin/fw_printenv-nand" ]]; then
		ln -sf /sbin/fw_printenv-nand /sbin/fw_printenv
	fi
	sed -i "/mmcblk/ s/^#*/#/" /etc/fw_env.config
	sed -i "s/#*\/dev\/mtd/\/dev\/mtd/" /etc/fw_env.config
}

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

	if [[ $ROOTFS_DEV == "emmc" ]] ; then
		echo
		echo "Setting U-Boot enviroment variables"
		set_fw_utils_to_nand
		fw_setenv rootfs_device emmc  2> /dev/null

		if [[ $swupdate == 1 ]] ; then
			fw_setenv mmcrootpart 1
			fw_setenv boot_device emmc
			fw_setenv bootdir /boot
		fi
	fi
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
		/usr/bin/install_yocto_emmc.sh ${EMMC_EXTRA_ARGS}
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
	echo " -u			create two rootfs partitions (for swUpdate double-copy) - ignored in case of NAND rootfs device."
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

while getopts :b:t:r:u OPTION;
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
	u)
		swupdate=1
		EMMC_EXTRA_ARGS="-u"
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
	if [[ $swupdate == 1 ]] ; then
		blue_bold_echo "Creating two rootfs partitions"
	fi
	/usr/bin/install_yocto_emmc.sh -b dart ${EMMC_EXTRA_ARGS}
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

if [[ $ROOTFS_DEV == "emmc" ]] && [[ $swupdate == 1 ]] ; then
	blue_bold_echo "Creating two rootfs partitions"
fi

install_bootloader

if [[ $ROOTFS_DEV != "emmc" ]] || [[ $swupdate != 1 ]] ; then
	install_kernel
fi

install_rootfs

finish
