#!/bin/bash
# Meant to be called by install_android.sh
set -e

. /usr/bin/echos.sh

# Partition sizes in MiB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=32
RECOVERY_ROM_SIZE=32
SYSTEM_ROM_SIZE=1536
CACHE_SIZE=512
DEVICE_SIZE=8
MISC_SIZE=4
DATAFOOTER_SIZE=2
METADATA_SIZE=2
FBMISC_SIZE=1
PRESISTDATA_SIZE=1

help() {

	bn=`basename $0`
	echo " usage $bn <option> device_node"
	echo
	echo " options:"
	echo " -h			displays this help message"
	echo " -s			only get partition size"
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
	    -s) cal_only=1 ;;
	    -f) soc_name=$2; shift;;
	    *)  moreoptions=0; block=$1; is_dart=$2 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 2 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

systemimage_file="system_raw.img"
bootimage_file="boot-${soc_name}.img"
recoveryimage_file="recovery-${soc_name}.img"
imagesdir=/opt/images/Android
node=/dev/${block}
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

# Call sfdisk to create partition table
# Get total card size
seprate=100
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} \/ 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
extend_size=`expr ${SYSTEM_ROM_SIZE} + ${CACHE_SIZE} + ${DEVICE_SIZE} + ${MISC_SIZE} + ${FBMISC_SIZE} + ${PRESISTDATA_SIZE} + ${DATAFOOTER_SIZE} + ${METADATA_SIZE} +  ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${RECOVERY_ROM_SIZE} - ${extend_size}`

# Echo partitions
cat << EOF
TOTAL    : ${total_size}MB
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

if [[ $cal_only == 1 ]] ; then
exit 0
fi

function check_images
{
	if [[ ! -b $node ]] ; then
		red_bold_echo "ERROR: \"$node\" is not a block device"
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
	blue_underlined_bold_echo "Creating Android partitions"

	SECT_SIZE_BYTES=`cat /sys/block/${block}/queue/hw_sector_size`
	BOOTLOAD_RESERVE_sect=`expr $BOOTLOAD_RESERVE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	boot_rom_sizeb_sect=`expr $boot_rom_sizeb \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	RECOVERY_ROM_SIZE_sect=`expr $RECOVERY_ROM_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	extend_size_sect=`expr $extend_size \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	SYSTEM_ROM_SIZE_sect=`expr $SYSTEM_ROM_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	CACHE_SIZE_sect=`expr $CACHE_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	DEVICE_SIZE_sect=`expr $DEVICE_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	MISC_SIZE_sect=`expr $MISC_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	DATAFOOTER_SIZE_sect=`expr $DATAFOOTER_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	METADATA_SIZE_sect=`expr $METADATA_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	FBMISC_SIZE_sect=`expr $FBMISC_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
	PRESISTDATA_SIZE_sect=`expr $PRESISTDATA_SIZE \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`

sfdisk --force -uS ${node} &> /dev/null << EOF
,${boot_rom_sizeb_sect},83
,${RECOVERY_ROM_SIZE_sect},83
,${extend_size_sect},5
,-,83
,${SYSTEM_ROM_SIZE_sect},83
,${CACHE_SIZE_sect},83
,${DEVICE_SIZE_sect},83
,${MISC_SIZE_sect},83
,${DATAFOOTER_SIZE_sect},83
,${METADATA_SIZE_sect},83
,${FBMISC_SIZE_sect},83
,${PRESISTDATA_SIZE_sect},83
EOF

	sync; sleep 1

	if [[ $is_dart == true ]] ; then
		# Adjust the partition reserve for bootloader.
		((echo d; echo 1; echo w) | fdisk $node > /dev/null)
		sync; sleep 1
		((echo n; echo p; echo $BOOTLOAD_RESERVE_sect; echo; echo w) | fdisk -u $node > /dev/null)
		sync; sleep 1
	fi

	fdisk -u -l $node
}

function install_bootloader
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	if [[ $is_dart == true ]] ; then
		dd if=${imagesdir}/SPL-mmc of=$node bs=1k seek=1; sync

		dd if=${imagesdir}/u-boot-var-imx6-mmc.img of=$node bs=1k seek=69; sync
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
	echo
	blue_underlined_bold_echo "Formating Android partitions"
	mkfs.ext4 ${node}${part}4 -Ldata
	mkfs.ext4 ${node}${part}5 -Lsystem
	mkfs.ext4 ${node}${part}6 -Lcache
	mkfs.ext4 ${node}${part}7 -Ldevice
	sync; sleep 1
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
	dd if=${imagesdir}/${systemimage_file} of=${node}${part}5
	sync; sleep 1
}

check_images

umount ${node}${part}*  2> /dev/null || true

delete_device
create_parts
install_bootloader
format_android
install_android

exit 0
