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
VENDOR_SIZE=112
MISC_SIZE=4
DATAFOOTER_SIZE=2
METADATA_SIZE=2
PRESISTDATA_SIZE=1
FBMISC_SIZE=1

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

systemimage_file="system_raw.img.gz"
vendorimage_file="vendor_raw.img.gz"
bootimage_file="boot-${soc_name}.img"
recoveryimage_file="recovery-${soc_name}.img"
imagesdir=/opt/images/Android
node=/dev/${block}
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi


if [[ $is_dart != true ]] ; then
	BOOTLOAD_RESERVE=0
fi

# Get total device size
seprate=100
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} \/ 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
extend_size=`expr ${SYSTEM_ROM_SIZE} + ${CACHE_SIZE} + ${VENDOR_SIZE} + ${MISC_SIZE} + ${FBMISC_SIZE} + ${PRESISTDATA_SIZE} + ${DATAFOOTER_SIZE} + ${METADATA_SIZE} + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${RECOVERY_ROM_SIZE} - ${extend_size}`

# Echo partitions
cat << EOF
TOTAL            : ${total_size} MiB
U-BOOT (on eMMC) : ${BOOTLOAD_RESERVE} MiB
BOOT             : ${BOOT_ROM_SIZE} MiB
RECOVERY         : ${RECOVERY_ROM_SIZE} MiB
SYSTEM           : ${SYSTEM_ROM_SIZE} MiB
CACHE            : ${CACHE_SIZE} MiB
MISC             : ${MISC_SIZE} MiB
DATAFOOTER       : ${DATAFOOTER_SIZE} MiB
METADATA         : ${METADATA_SIZE} MiB
PRESISTDATA      : ${PRESISTDATA_SIZE} MiB
VENDOR		 : ${VENDOR_SIZE} MiB
USERDATA         : ${data_size} MiB
FBMISC           : ${FBMISC_SIZE} MiB
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
	if [[ ! -f ${imagesdir}/${vendorimage_file} ]] ; then
		red_bold_echo "ERROR: vendor image does not exist"
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
			dd if=/dev/zero of=${node}${part}${i} bs=1024 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	sgdisk -Z $node
	sync

	dd if=/dev/zero of=$node bs=1M count=4
	sync; sleep 1
}

function create_parts
{
	echo
	blue_underlined_bold_echo "Creating Android partitions"

	sgdisk -n 1:${BOOTLOAD_RESERVE}M:+${BOOT_ROM_SIZE}M -c 1:"boot"        -t 1:8300  $node
	sgdisk -n 2:0:+${RECOVERY_ROM_SIZE}M                -c 2:"recovery"    -t 2:8300  $node
	sgdisk -n 3:0:+${SYSTEM_ROM_SIZE}M                  -c 3:"system"      -t 3:8300  $node
	sgdisk -n 4:0:+${CACHE_SIZE}M                       -c 4:"cache"       -t 4:8300  $node
	sgdisk -n 5:0:+${MISC_SIZE}M                        -c 5:"misc"        -t 5:8300  $node
	sgdisk -n 6:0:+${DATAFOOTER_SIZE}M                  -c 6:"datafooter"  -t 6:8300  $node
	sgdisk -n 7:0:+${METADATA_SIZE}M                    -c 7:"metadata"    -t 7:8300  $node
	sgdisk -n 8:0:+${PRESISTDATA_SIZE}M                 -c 8:"presistdata" -t 8:8300  $node
	sgdisk -n 9:0:+${VENDOR_SIZE}M			    -c 9:"vendor"      -t 9:8300  $node
	sgdisk -n 10:0:+${data_size}M                       -c 10:"userdata"   -t 10:8300 $node
	sgdisk -n 11:0:+${FBMISC_SIZE}M                     -c 11:"fbmisc"     -t 11:0700 $node

	sync; sleep 2

	for i in `cat /proc/mounts | grep "${node}" | awk '{print $2}'`; do umount $i; done
	hdparm -z $node
	# backup the GPT table to last LBA.
	echo -e 'r\ne\nY\nw\nY\nY' |  gdisk $node
	sync; sleep 1
	sgdisk -p $node
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
	mkfs.ext4 -F ${node}${part}3 -Lsystem
	mkfs.ext4 -F ${node}${part}4 -Lcache
	mkfs.ext4 -F ${node}${part}9 -Lvendor
	mkfs.ext4 -F ${node}${part}10 -Ldata
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
	zcat ${imagesdir}/${systemimage_file} | dd of=${node}${part}3
	sync; sleep 1

	echo
	blue_underlined_bold_echo "Installing Android vendor image: $vendorimage_file"
	zcat ${imagesdir}/${vendorimage_file} | dd of=${node}${part}9
	sync; sleep 1
}

# Stop udev daemon to prevent automatic mounting
# of newly created eMMC partitions
stop_udev()
{
	# SystemV init
	if [ -x /etc/init.d/udev ]; then
		/etc/init.d/udev stop
		return
	fi

	# Systemd
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl mask --runtime systemd-udevd
		systemctl stop systemd-udevd
	fi
}

start_udev()
{
	# SystemV init
	if [ -x /etc/init.d/udev ]; then
		/etc/init.d/udev start
		return
	fi

	# Systemd
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl unmask --runtime systemd-udevd
		systemctl start systemd-udevd
	fi
}

check_images

#Stop Udev for block devices while partitioning in progress
stop_udev

umount ${node}${part}*  2> /dev/null || true

delete_device
create_parts
install_bootloader
format_android
install_android

echo
#Start Udev back before exit
start_udev

exit 0
