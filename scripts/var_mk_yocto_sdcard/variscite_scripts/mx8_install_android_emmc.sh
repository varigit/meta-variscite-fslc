#!/bin/bash
# Meant to be called by install_android.sh
set -e

. /usr/bin/echos.sh

# Partition sizes in MiB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=32
SYSTEM_ROM_SIZE=1536
MISC_SIZE=4
METADATA_SIZE=2
PRESISTDATA_SIZE=1
VENDOR_ROM_SIZE=112
FBMISC_SIZE=1
VBMETA_SIZE=1

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
block="mmcblk0"

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
		-h) help; exit ;;
		-s) cal_only=1 ;;
		-f) soc_name=$2; shift;;
		*)  moreoptions=0 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 2 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

imagesdir="/opt/images/Android"
bootimage_file="boot-${soc_name}.img"
vbmeta_file="vbmeta-${soc_name}.img"
systemimage_raw_file="system_raw.img"
vendorimage_raw_file="vendor_raw.img"

node=/dev/${block}
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

if [[ "${soc_name}" = *"mx8d"* ]]; then
	bootloader_offset=16
fi

bootloader_file="u-boot-var-imx6-sd.img"
bootloader_offset=1

if [[ "${soc_name}" = *"mx8m"* ]]; then
	bootloader_offset=33
	bootloader_file="u-boot-imx8m-var-dart.imx"
fi

if [[ "${soc_name}" = *"mx8q"* ]]; then
	bootloader_offset=33
	bootloader_file="u-boot-imx8q-var-spear.imx"
fi

echo "${soc_name} bootloader offset is: ${bootloader_offset}"
echo "${soc_name} bootloader is: ${bootloader_file}"

# Get total device size
seprate=100
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} \/ 1024`
boot_rom_sizeb=`expr ${BOOTLOAD_RESERVE} + ${BOOT_ROM_SIZE} \* 2`
extend_size=`expr ${SYSTEM_ROM_SIZE} \* 2 + ${MISC_SIZE} + ${METADATA_SIZE} + ${PRESISTDATA_SIZE} + ${VENDOR_ROM_SIZE} \* 2 + ${FBMISC_SIZE} + ${VBMETA_SIZE} \* 2 + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${extend_size}`

# Echo partitions
cat << EOF
TOTAL            : ${total_size} MiB
U-BOOT (on eMMC) : ${BOOTLOAD_RESERVE} MiB
BOOT_A           : ${BOOT_ROM_SIZE} MiB
BOOT_B           : ${BOOT_ROM_SIZE} MiB
SYSTEM_A         : ${SYSTEM_ROM_SIZE} MiB
SYSTEM_B         : ${SYSTEM_ROM_SIZE} MiB
MISC             : ${MISC_SIZE} MiB
METADATA         : ${METADATA_SIZE} MiB
PRESISTDATA      : ${PRESISTDATA_SIZE} MiB
VENDOR_A         : ${VENDOR_ROM_SIZE} MiB
VENDOR_B         : ${VENDOR_ROM_SIZE} MiB
USERDATA         : ${data_size} MiB
FBMISC           : ${FBMISC_SIZE} MiB
VBMETA_A         : ${VBMETA_SIZE} MiB
VBMETA_B         : ${VBMETA_SIZE} MiB
EOF

echo

if [[ $cal_only == 1 ]] ; then
exit 0
fi

function check_images
{
	if [[ ! -b $node ]] ; then
		red_bold_echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootloader_file} ]] ; then
		red_bold_echo "ERROR: U-Boot image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootimage_file} ]] ; then
		red_bold_echo "ERROR: boot image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${systemimage_raw_file} ]] ; then
		red_bold_echo "ERROR: system image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${vendorimage_raw_file} ]] ; then
		red_bold_echo "ERROR: vendor image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${vbmeta_file} ]] ; then
		red_bold_echo "ERROR: vbmeta image does not exist"
		exit 1
	fi
}

function delete_device
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"
	for ((i=0; i<=12; i++))
	do
		if [[ -e ${node}${part}${i} ]] ; then
			dd if=/dev/zero of=${node}${part}${i} bs=1M count=1 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	sgdisk -Z $node
	sync

	dd if=/dev/zero of=$node bs=1M count=8
	sync; sleep 1
}

function create_parts
{
	echo
	blue_underlined_bold_echo "Creating Android partitions"

	sgdisk -n 1:${BOOTLOAD_RESERVE}M:+${BOOT_ROM_SIZE}M -c 1:"boot_a"      -t 1:8300  $node
	sgdisk -n 2:0:+${BOOT_ROM_SIZE}M                    -c 2:"boot_b"      -t 2:8300  $node
	sgdisk -n 3:0:+${SYSTEM_ROM_SIZE}M                  -c 3:"system_a"    -t 3:8300  $node
	sgdisk -n 4:0:+${SYSTEM_ROM_SIZE}M                  -c 4:"system_b"    -t 4:8300  $node
	sgdisk -n 5:0:+${MISC_SIZE}M                        -c 5:"misc"        -t 5:8300  $node
	sgdisk -n 6:0:+${METADATA_SIZE}M                    -c 6:"metadata"    -t 6:8300  $node
	sgdisk -n 7:0:+${PRESISTDATA_SIZE}M                 -c 7:"presistdata" -t 7:8300  $node
	sgdisk -n 8:0:+${VENDOR_ROM_SIZE}M                  -c 8:"vendor_a"    -t 8:8300  $node
	sgdisk -n 9:0:+${VENDOR_ROM_SIZE}M                  -c 9:"vendor_b"    -t 9:8300  $node
	sgdisk -n 10:0:+${data_size}M                       -c 10:"userdata"   -t 10:8300 $node
	sgdisk -n 11:0:+${FBMISC_SIZE}M                     -c 11:"fbmisc"     -t 11:8300 $node
	sgdisk -n 12:0:+${VBMETA_SIZE}M                     -c 12:"vbmeta_a"   -t 12:8300 $node
	sgdisk -n 13:0:+${VBMETA_SIZE}M                     -c 13:"vbmeta_b"   -t 13:8300 $node

	sync; sleep 2

	for i in `cat /proc/mounts | grep "${node}" | awk '{print $2}'`; do umount $i; done
	hdparm -z $node
	sync; sleep 3

	# backup the GPT table to last LBA.
	echo -e 'r\ne\nY\nw\nY\nY' |  gdisk $node
	sync; sleep 1
	sgdisk -p $node
}

function install_bootloader
{
	echo
	blue_underlined_bold_echo "Installing booloader"

	dd if=${imagesdir}/${bootloader_file} of=$node bs=1k seek=${bootloader_offset}; sync
}

function format_android
{
	echo
	blue_underlined_bold_echo "Erasing presistdata partition"
	dd if=/dev/zero of=${node}${part}7 bs=1M count=${PRESISTDATA_SIZE} conv=fsync
	blue_underlined_bold_echo "Erasing fbmisc partition"
	dd if=/dev/zero of=${node}${part}11 bs=1M count=${FBMISC_SIZE} conv=fsync
	blue_underlined_bold_echo "Erasing misc partition"
	dd if=/dev/zero of=${node}${part}5 bs=1M count=${MISC_SIZE} conv=fsync
	blue_underlined_bold_echo "Formating userdata partition"
	mkfs.ext4 -F ${node}${part}10 -Ldata
	sync; sleep 1
}

function install_android
{
	echo
	blue_underlined_bold_echo "Installing Android boot image: $bootimage_file"
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}1
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}2
	sync

	echo
	blue_underlined_bold_echo "Installing Android system image: $systemimage_raw_file"
	dd if=${imagesdir}/${systemimage_raw_file} of=${node}${part}3
	dd if=${imagesdir}/${systemimage_raw_file} of=${node}${part}4
	sync;

	echo
	blue_underlined_bold_echo "Installing Android vendor image: $vendorimage_raw_file"
	dd if=${imagesdir}/${vendorimage_raw_file} of=${node}${part}8
	dd if=${imagesdir}/${vendorimage_raw_file} of=${node}${part}9
	sync;

	echo
	blue_underlined_bold_echo "Installing Android vbmeta image: $vbmeta_file"
	dd if=${imagesdir}/${vbmeta_file} of=${node}${part}12
	dd if=${imagesdir}/${vbmeta_file} of=${node}${part}13
	sync;

	sleep 1
}

check_images

umount ${node}${part}*  2> /dev/null || true

#Stop Udev for block devices while partitioning in progress
#/etc/init.d/udev stop

delete_device
create_parts
install_bootloader
format_android
install_android

echo
#Start Udev back before exit
#/etc/init.d/udev restart

exit 0
