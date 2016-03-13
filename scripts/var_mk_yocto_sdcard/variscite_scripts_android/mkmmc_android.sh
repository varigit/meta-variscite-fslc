#!/bin/bash

# Partition sizes in MiB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=16
SYSTEM_ROM_SIZE=512
CACHE_SIZE=512
RECOVERY_ROM_SIZE=16
DEVICE_SIZE=8
MISC_SIZE=6
DATAFOOTER_SIZE=2


help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h				displays this help message
  -s				only get partition size
  -np 				not partition.
  -f soc_name			flash android image.
  -u soc_name			format partition and flash u-boot (prepare for FASTBOOT).
EOF

}

# parse command line
moreoptions=1
node="na"
soc_name=""
cal_only=0
flash_images=0
not_partition=0
not_format_fs=0
systemimage_file="system.img"

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
	    -s) cal_only=1 ;;
	    -f) flash_images=1 ; soc_name=$2; shift;;
	    -u) flash_images=0 ; soc_name=$2; shift;;
	    -np) not_partition=1 ;;
	    -nf) not_format_fs=1 ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

if [ `dmesg |grep VAR-DART | wc -l` = 1 ] ; then
	node=/dev/mmcblk2
	mmm=/run/media/mmcblk2p
else
	node=/dev/mmcblk1
	mmm=/run/media/mmcblk1p
fi

part=""
echo ${node} | grep mmcblk > /dev/null
if [ "$?" -eq "0" ]; then
	part="p"
fi

umount ${mmm}1 2>/dev/null
umount ${mmm}2 2>/dev/null
umount ${mmm}3 2>/dev/null
umount ${mmm}4 2>/dev/null
umount ${mmm}5 2>/dev/null
umount ${mmm}6 2>/dev/null
umount ${mmm}7 2>/dev/null
umount ${mmm}8 2>/dev/null
umount ${mmm}9 2>/dev/null

# Destroy the partition table
dd if=/dev/zero of=${node} bs=512 count=1
sync

# Call sfdisk to create partition table
# Get total card size
seprate=40
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
echo "TOTAl SIZE ${total_size}MiB"
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
extend_size=`expr ${SYSTEM_ROM_SIZE} + ${CACHE_SIZE} + ${DEVICE_SIZE} + ${MISC_SIZE} + ${DATAFOOTER_SIZE} + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${RECOVERY_ROM_SIZE} - ${extend_size} + ${seprate}`

# Echo partitions
cat << EOF
U-BOOT   : ${BOOTLOAD_RESERVE}MiB
BOOT     : ${BOOT_ROM_SIZE}MiB
RECOVERY : ${RECOVERY_ROM_SIZE}MiB
SYSTEM   : ${SYSTEM_ROM_SIZE}MiB
CACHE    : ${CACHE_SIZE}MiB
DATA     : ${data_size}MiB
MISC     : ${MISC_SIZE}MiB
DEVICE   : ${DEVICE_SIZE}MiB
DATAFOOTER : ${DATAFOOTER_SIZE}MiB
EOF
if [ "${cal_only}" -eq "1" ]; then
exit
fi

function install_bootloader
{
	cd /opt/images/Android/Emmc

	if [ `dmesg | grep VAR-DART | wc -l` = 1 ] ; then
		echo "Flashing SPL to eMMC"
		dd if=SPL.mmc of=/dev/mmcblk2 bs=1k seek=1;sync

		echo "Flashing U-Boot to eMMC"
		dd if=u-boot-var-imx6-sd.img of=/dev/mmcblk2 bs=1k seek=69;sync
	else
		echo "Flashing SPL to NAND "
		flash_erase /dev/mtd0 0 0 2>/dev/null
		kobs-ng init -x SPL --search_exponent=1 -v > /dev/null

		echo "Flashing U-Boot to NAND"
		flash_erase /dev/mtd1 0 0  2>/dev/null
		nandwrite -p /dev/mtd1 u-boot-var-imx6-nand.img 
	fi
	sync
}

function format_android
{
	echo "formating android partition"
	mkfs.ext4 ${node}${part}4 -Ldata
	mkfs.ext4 ${node}${part}5 -Lsystem
	mkfs.ext4 ${node}${part}6 -Lcache
	mkfs.ext4 ${node}${part}7 -Ldevice
	sync
}

function flash_android
{
	bootimage_file="boot-${soc_name}.img"
	recoveryimage_file="recovery-${soc_name}.img"

	cd /opt/images/Android/Emmc
	echo "flashing Android boot image: ${bootimage_file}"
	dd if=${bootimage_file} of=${node}${part}1
	sync

	echo "flashing Android recovery image: ${recoveryimage_file}"
	dd if=${recoveryimage_file} of=${node}${part}2
	sync

	echo "flashing Android system image: ${systemimage_file}"
	dd if=${systemimage_file} of=${node}${part}5
	sync
}

echo "Create Android partition table"

sfdisk --force -uM ${node} << EOF
,${boot_rom_sizeb},83
,${RECOVERY_ROM_SIZE},83
,${extend_size},5
,${data_size},83
,${SYSTEM_ROM_SIZE},83
,${CACHE_SIZE},83
,${DEVICE_SIZE},83
,${MISC_SIZE},83
,${DATAFOOTER_SIZE},83
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


if [ `dmesg |grep VAR-DART | wc -l` = 1 ] ; then
# adjust the partition reserve for bootloader.
# if you don't put the uboot on same device, you can remove the BOOTLOADER_ERSERVE
# to have 8M space.
# the minimal sylinder for some card is 4M, maybe some was 8M
# just 8M for some big eMMC 's sylinder
echo "Adjust DART eMMC partition table. Reserve space for bootloader"
#sfdisk --force -uM ${node} -N1 << EOF
#${BOOTLOAD_RESERVE},${BOOT_ROM_SIZE},83
#EOF
fdisk ${node} <<EOF
d
1
w
EOF
umount ${mmm}* 2>/dev/null

fdisk ${node} <<EOF
n
p
8192

w
q
EOF

umount ${mmm}* 2>/dev/null

fi

umount ${mmm}1 2>/dev/null
umount ${mmm}2 2>/dev/null
umount ${mmm}3 2>/dev/null
umount ${mmm}4 2>/dev/null
umount ${mmm}5 2>/dev/null
umount ${mmm}6 2>/dev/null
umount ${mmm}7 2>/dev/null
umount ${mmm}8 2>/dev/null
umount ${mmm}9 2>/dev/null

# Delete information on data partition
echo "Clear data partition ${node}${part}4"
dd if=/dev/zero of=${node}${part}4 bs=1K count=1000

sync;sleep 3;
format_android
sync;sleep 3;
install_bootloader
sync;sleep 3;
flash_android
sync;sleep 3;

umount ${mmm}1 2>/dev/null
umount ${mmm}2 2>/dev/null
umount ${mmm}3 2>/dev/null
umount ${mmm}4 2>/dev/null
umount ${mmm}5 2>/dev/null
umount ${mmm}6 2>/dev/null
umount ${mmm}7 2>/dev/null
umount ${mmm}8 2>/dev/null
umount ${mmm}9 2>/dev/null

exit 0
