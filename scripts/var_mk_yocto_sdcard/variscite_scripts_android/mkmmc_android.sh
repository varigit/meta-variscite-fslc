#!/bin/bash

# Partition sizes in MiB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=16
RECOVERY_ROM_SIZE=16
SYSTEM_ROM_SIZE=512
CACHE_SIZE=512
DEVICE_SIZE=8
MISC_SIZE=6
DATAFOOTER_SIZE=2


help() {

	bn=`basename $0`
	echo " usage $bn <option> device_node"
	echo
	echo " options:"
	echo " -h			displays this help message"
	echo " -s			only get partition size"
	echo " -np 			not partition."
	echo " -f soc_name		flash android image."
	echo " -u soc_name		format partition and flash u-boot (prepare for FASTBOOT)."
}

# Parse command line
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

if [ `dmesg | grep VAR-DART | wc -l` = 1 ] ; then
	block=mmcblk2
	node=/dev/$block
	mmm=/run/media/${block}p
else
	block=mmcblk0
	node=/dev/$block
	mmm=/run/media/${block}p
fi

part=""
echo ${node} | grep mmcblk > /dev/null
if [ "$?" -eq "0" ]; then
	part="p"
fi

umount ${mmm}* 2>/dev/null


for ((i=0; i<=10; i++))
do
	if [[ -e ${node}${part}${i} ]] ; then
		dd if=/dev/zero of=${node}${part}$i bs=512 count=1024
	fi
done
sync

((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk ${node} &> /dev/null)
sync

dd if=/dev/zero of=${node} bs=512 count=1024
sync

# Call sfdisk to create partition table
# Get total card size
seprate=40
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
echo "TOTAL SIZE ${total_size}MiB"
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
		dd if=SPL-mmc of=$node bs=1k seek=1;sync

		echo "Flashing U-Boot to eMMC"
		dd if=u-boot-var-imx6-mmc.img of=$node bs=1k seek=69;sync
	else
		echo "Flashing SPL to NAND "
		flash_erase /dev/mtd0 0 0 2>/dev/null
		kobs-ng init -x SPL-nand --search_exponent=1 -v > /dev/null

		echo "Flashing U-Boot to NAND"
		flash_erase /dev/mtd1 0 0  2>/dev/null
		nandwrite -p /dev/mtd1 u-boot-var-imx6-nand.img 
	fi
	sync
}

function format_android
{
	echo "Formating Android partitions"
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
	echo
	echo "Flashing Android boot image: ${bootimage_file}"
	dd if=${bootimage_file} of=${node}${part}1
	sync

	echo
	echo "Flashing Android recovery image: ${recoveryimage_file}"
	dd if=${recoveryimage_file} of=${node}${part}2
	sync

	echo
	echo "Flashing Android system image: ${systemimage_file}"
	dd if=${systemimage_file} of=${node}${part}5
	sync
}

SECT_SIZE_BYTES=`cat /sys/block/${block}/queue/hw_sector_size`
boot_rom_sizeb_sect=`expr $boot_rom_sizeb \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
RECOVERY_ROM_SIZE_sect=`expr $RECOVERY_ROM_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
extend_size_sect=`expr $extend_size \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
data_size_sect=`expr $data_size \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
SYSTEM_ROM_SIZE_sect=`expr $SYSTEM_ROM_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
CACHE_SIZE_sect=`expr $CACHE_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
DEVICE_SIZE_sect=`expr $DEVICE_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
MISC_SIZE_sect=`expr $MISC_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
DATAFOOTER_SIZE_sect=`expr $DATAFOOTER_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`

echo "Creating Android partitions"
sfdisk --force -uS ${node} << EOF
,${boot_rom_sizeb_sect},83
,${RECOVERY_ROM_SIZE_sect},83
,${extend_size_sect},5
,${data_size_sect},83
,${SYSTEM_ROM_SIZE_sect},83
,${CACHE_SIZE_sect},83
,${DEVICE_SIZE_sect},83
,${MISC_SIZE_sect},83
,${DATAFOOTER_SIZE_sect},83
EOF
if [ "$?" = "0" ]; then
	sync
	sleep 4
else
	echo -e "\e[31msfdisk error!\e[0m"
	echo "============"
	exit 1
fi


if [[ `dmesg | grep VAR-DART | wc -l` == 1 ]] ; then
	# adjust the partition reserve for bootloader.
	# if you don't put the uboot on same device, you can remove the BOOTLOADER_ERSERVE
	# to have 8M space.
	# the minimal sylinder for some card is 4M, maybe some was 8M
	# just 8M for some big eMMC 's sylinder
	echo "Adjust DART eMMC partition table. Reserve space for bootloader"

	((echo d; echo 1; echo w) | fdisk $node)

	umount ${mmm}* 2>/dev/null

	((echo n; echo p; echo 8192; echo; echo w) | fdisk -u $node)
fi

umount ${mmm}* 2>/dev/null

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

umount ${mmm}* 2>/dev/null

exit 0
