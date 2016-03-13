#!/bin/sh
#
# NAND recovery version 50. Support Yocto V10.1 Fido and above and Android Lollipop V3

MEDIA=/opt/images

OS=Yocto

FLASH=Nand

UBOOT_IMAGE=u-boot.img
SPL_IMAGE=SPL
#
KERNEL_IMAGE=uImage
ROOTFS_IMAGE=rootfs.ubi.img
KERNEL_DTB=imx6q-var-som.dtb
#
ANDROID_BOOT=boot.img
ANDROID_RECOVERY=recovery.img
ANDROID_SYSTEM=android_root.img
UBI_SUB_PAGE_SIZE=2048
UBI_VID_HDR_OFFSET=2048

install_bootloader()
{
	if [ ! -f $MEDIA/$OS/$UBOOT_IMAGE ]
	then
		echo "\"$MEDIA/$OS/$UBOOT_IMAGE\"" does not exist! exit.
		exit 1
	fi	

	if [ ! -f $MEDIA/$OS/$SPL_IMAGE ]
	then
		echo "\"$MEDIA/$OS/$SPL_IMAGE\"" does not exist! exit.
		exit 1
	fi	

	echo "Installing SPL from \"$MEDIA/$OS/$SPL_IMAGE\"... "
	flash_erase /dev/mtd0 0 0 2>/dev/null
	kobs-ng init -x $MEDIA/$OS/$SPL_IMAGE --search_exponent=1 -v > /dev/null
	echo "Installing U-BOOT from \"$MEDIA/$OS/$UBOOT_IMAGE\"..."
	flash_erase /dev/mtd1  0 0  2>/dev/null
	nandwrite -p /dev/mtd1 $MEDIA/$OS/$UBOOT_IMAGE 
}

install_kernel()
{
	if [ ! -f $MEDIA/$OS/$KERNEL_IMAGE ]
	then
		echo "\"$MEDIA/$OS/$KERNEL_IMAGE\"" does not exist! exit.
		exit 1
	fi	
	echo "Installing Kernel ..."
	flash_erase /dev/mtd2 0 0 2>/dev/null
	nandwrite -p /dev/mtd2 $MEDIA/$OS/$KERNEL_IMAGE > /dev/null
	nandwrite -p /dev/mtd1 -s 0x1e0000 $MEDIA/$OS/$KERNEL_DTB > /dev/null
}

install_rootfs()
{
	if [ ! -f $MEDIA/$OS/$ROOTFS_IMAGE ]
	then
		echo "\"$MEDIA/$OS/$ROOTFS_IMAGE\"" does not exist! exit.
		exit 1
	fi	
	echo "Installing UBI rootfs ..."
	flash_erase /dev/mtd3 0 0 3>/dev/null
	ubiformat /dev/mtd3 -f $MEDIA/$OS/$ROOTFS_IMAGE -s $UBI_SUB_PAGE_SIZE -O $UBI_VID_HDR_OFFSET
}

# Partition Table
# 0 0x000000000000-0x000000200000 : "spl"
# 1 0x000000200000-0x000000400000 : "bootloader"
# 2 0x000000400000-0x000000a00000 : "kernel"
# 3 0x000000a00000-0x000020000000 : "rootfs"
# 4 0x000000400000-0x000001400000 : "android_boot"
# 5 0x000001400000-0x000003000000 : "android_recovery"
# 6 0x000003000000-0x000020000000 : "android_rootfs"

install_android_boot()
{
	if [ ! -f $MEDIA/$OS/$ANDROID_BOOT ]
	then
		echo "\"$MEDIA/$OS/$ANDROID_BOOT\"" does not exist! exit.
		exit 1
	fi
	echo "Installing boot.img ..."
	flash_erase /dev/mtd4 0 0 2>/dev/null
	nandwrite -p /dev/mtd4 $MEDIA/$OS/$ANDROID_BOOT > /dev/null
}

install_android_recovery()
{
	if [ ! -f $MEDIA/$OS/$ANDROID_RECOVERY ]
	then
		echo "\"$MEDIA/$OS/$ANDROID_RECOVERY\"" does not exist! exit.
		exit 1
	fi
	echo "Installing recovery.img ..."
	flash_erase /dev/mtd5 0 0 2>/dev/null
	nandwrite -p /dev/mtd5 $MEDIA/$OS/$ANDROID_RECOVERY > /dev/null
}	

install_android_system()
{
        if [ ! -f $MEDIA/$OS/$ANDROID_SYSTEM ]
	then
		echo "\"$MEDIA/$OS/$ANDROID_SYSTEM\"" does not exist! exit.
		exit 1
	fi
	echo "Installing system.img ..."
	flash_erase /dev/mtd6 0 0 2>/dev/null
	ubiformat /dev/mtd6 -f $MEDIA/$OS/$ANDROID_SYSTEM -s $UBI_SUB_PAGE_SIZE -O $UBI_VID_HDR_OFFSET
}
                                                                          
usage()
{
	cat << EOF
		usage: $0 options

		This script install Android(KitKat 443_200)/Yocto V8(Daisy) binaries in VAR-SOM-MX6 NAND or eMMC.

		OPTIONS:
		-h                       Show this message
		-o <Android|Yocto|Dora>  OS type (defualt: Yocto).
		-m <Nand|Emmc>  	 Media type (defualt: Nand).

EOF
}

while getopts :h:o:m: OPTION;
do
	case $OPTION in
	h)
		usage
		exit 1
		;;
	o)
		OS=$OPTARG
		;;
	m)
		FLASH=$OPTARG
		;;

	?)
		usage
		exit 1
	;;
	esac
done

if [[ "$OS" != "Yocto" ]] && [[ "$OS" != "Dora" ]] && [[ "$OS" != "Android" ]]
then
	usage
	exit 1
fi

if [[ "$FLASH" != "Nand" ]] && [[ "$FLASH" != "Emmc" ]] 
then
	usage
	exit 1
fi


if [ `dmesg | grep VAR-DART | wc -l` = 1 ] ; then
	/sbin/yocto-dart.sh
	exit $?
fi

echo "*** VAR-MX6 eMMC/NAND RECOVERY Version 50 ***"
echo "Installing $OS on $FLASH ..."

VSC=$(i2cdump  -y -r 0-0  1 0x51 b | tail -n 1)
VSC=${VSC:4:2}


if [ `cat /proc/cpuinfo |grep processor | wc -l` = 1 ] ; then
	if [ `dmesg |grep SOM-SOLO | wc -l` = 1 ] ; then
		if [[ "$VSC" == "ff" ]]
		then
			KERNEL_DTB=uImage-imx6dl-var-som-solo-vsc.dtb
		else
			KERNEL_DTB=uImage-imx6dl-var-som-solo.dtb
		fi
	else
	        KERNEL_DTB=uImage-imx6dl-var-som.dtb
	fi
fi

if [ `cat /proc/cpuinfo |grep processor | wc -l` = 2 ] ; then
	if [ `dmesg |grep SOM-SOLO | wc -l` = 1 ] ; then
		if [[ "$VSC" == "ff" ]]
		then
			KERNEL_DTB=uImage-imx6dl-var-som-solo-vsc.dtb
		else
			KERNEL_DTB=uImage-imx6dl-var-som-solo.dtb
		fi
	else
		if [ `dmesg |grep i.MX6DL | wc -l` = 1 ] ; then
			KERNEL_DTB=uImage-imx6dl-var-som.dtb
		else
			KERNEL_DTB=uImage-imx6q-var-som.dtb
		fi
	fi
fi


if [ `cat /proc/cpuinfo |grep processor | wc -l` = 4 ] ; then
	if [[ "$VSC" == "ff" ]]
	then
		KERNEL_DTB=uImage-imx6q-var-som-vsc.dtb
	else
		KERNEL_DTB=uImage-imx6q-var-som.dtb
	fi

fi

echo "Using $KERNEL_DTB Device tree"

#if [ `dmesg |grep MT29F8G08ABABAWP | wc -l` = 1 ] ; then
#	# this is 1GB NAND (MT29F8G08ABABAWP)
#	ROOTFS_IMAGE=rootfs_1G_NAND.ubi.img
#	ANDROID_SYSTEM=android_root_1G_NAND.img
#	UBI_SUB_PAGE_SIZE=4096
#	UBI_VID_HDR_OFFSET=4096
#fi

echo "Flashing $OS into $FLASH"

if [[ "$OS" == "Android" ]] && [[ "$FLASH" == "Emmc" ]] 
then
	OS="Android/Emmc"
fi

#if [[ "$OS" == "Yocto" ]] && [[ "$FLASH" == "Emmc" ]] 
#then
#	OS="Yocto/Emmc"
#fi


if [ "$FLASH" != "Emmc" ] ; then
# Flash to NAND	
	install_bootloader
	if [ "$OS" != "Android" ] ; then
		install_kernel
		install_rootfs
	else
	   echo "=========================================="
	   echo " Android nand not supported               "
	   echo "=========================================="
	fi
else
# Flash to eMMC
	if [ "$OS" != "Android/Emmc" ] ; then
		install_bootloader
		install_kernel
		. /sbin/mkmmc_yocto.sh
		echo "Setting rootfs location to emmc in u-boot enviroment"
		fw_setenv chosen_rootfs emmc
		echo "Done"

	else
	   echo "=========================================="
	   echo " Please use android-emmc.sh to flash eMMC "
	   echo "=========================================="
	fi
fi

exit 0
