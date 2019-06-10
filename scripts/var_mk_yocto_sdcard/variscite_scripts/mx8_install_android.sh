#!/bin/bash
# Meant to be called by install_android.sh
set -e

. /usr/bin/echos.sh

# Partition sizes in MiB
BOOTLOAD_RESERVE=8
DTBO_ROM_SIZE=4
BOOT_ROM_SIZE=48
SYSTEM_ROM_SIZE=1792
MISC_SIZE=4
METADATA_SIZE=2
PRESISTDATA_SIZE=1
VENDOR_ROM_SIZE=256
FBMISC_SIZE=1
VBMETA_SIZE=1

sdshared=false
if grep -q "i.MX8MM" /sys/devices/soc0/soc_id; then
	soc_name=imx8mm-var-dart
	node=/dev/mmcblk2
elif grep -q "i.MX8M" /sys/devices/soc0/soc_id; then
	soc_name=imx8mq-var-dart
	node=/dev/mmcblk0
	sdshared=true
else
	red_bold_echo "ERROR: Unsupported board"
	exit 1	
fi

imagesdir="/opt/images/Android"

img_prefix="dtbo-"
img_search_str="ls ${imagesdir}/${img_prefix}*"
if [ "$sdshared" = true ] ; then
	img_search_str+=" | grep -v sd"
fi
img_list=()

# generate options list
for img in $(eval $img_search_str)
do
	img=$(basename $img .img)
	img=${img#${img_prefix}}
	img_list+=($img)
done

# check for dtb
if [[ $soc_name != "showoptions" ]] && [[ ! ${img_list[@]} =~ $soc_name ]] ; then
	echo; red_bold_echo "ERROR: invalid dtb $soc_name"
	soc_name=showoptions
fi

if [[ $soc_name == "showoptions" ]] || [[ ${#img_list[@]} > 1 ]] ; then
	PS3='Please choose your configuration: '
	select opt in "${img_list[@]}"
	do
		if [[ -z "$opt" ]] ; then
			echo invalid option
			continue
		else
			soc_name=$opt
			break
		fi
	done
fi

dtboimage_file="dtbo-${soc_name}.img"
bootimage_file="boot.img"
vbmeta_file="vbmeta-${soc_name}.img"
systemimage_file="system.img"
vendorimage_file="vendor.img"

block=`basename $node`
part=""
if [[ $block == mmcblk* ]] ; then
	part="p"
fi

if [[ "${soc_name}" = *"mx8d"* ]]; then
	bootloader_offset=16
fi

bootloader_file="u-boot-var-imx6-sd.img"
bootloader_offset=1

if [[ "${soc_name}" = *"mx8mq"* ]]; then
	bootloader_offset=33
	bootloader_file="u-boot-imx8mq-var-dart.imx"
fi

if [[ "${soc_name}" = *"mx8mm"* ]]; then
	bootloader_offset=33
	bootloader_file="u-boot-imx8mm-var-dart.imx"
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
boot_rom_sizeb=`expr ${BOOTLOAD_RESERVE} + ${DTBO_ROM_SIZE} \* 2 + ${BOOT_ROM_SIZE} \* 2`
extend_size=`expr ${SYSTEM_ROM_SIZE} \* 2 + ${MISC_SIZE} + ${METADATA_SIZE} + ${PRESISTDATA_SIZE} + ${VENDOR_ROM_SIZE} \* 2 + ${FBMISC_SIZE} + ${VBMETA_SIZE} \* 2 + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${extend_size}`

# Echo partitions
cat << EOF
TOTAL            : ${total_size} MiB
U-BOOT (on eMMC) : ${BOOTLOAD_RESERVE} MiB
DTBO_A           : ${DTBO_ROM_SIZE} MiB
DTBO_B           : ${DTBO_ROM_SIZE} MiB
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

	if [[ ! -f ${imagesdir}/${dtboimage_file} ]] ; then
		red_bold_echo "ERROR: boot image does not exist"
		exit 1
	fi

	if [[ ! -f ${imagesdir}/${bootimage_file} ]] ; then
		red_bold_echo "ERROR: boot image does not exist"
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

	if [[ ! -f ${imagesdir}/${vbmeta_file} ]] ; then
		red_bold_echo "ERROR: vbmeta image does not exist"
		exit 1
	fi
}

function delete_device
{
	echo
	blue_underlined_bold_echo "Deleting current partitions"
	for partition in ${node}*
	do
		if [[ ${partition} = ${node} ]] ; then
			# skip base node
			continue
		fi
		if [[ ! -b ${partition} ]] ; then
			red_bold_echo "ERROR: \"${partition}\" is not a block device"
			exit 1
		fi
		dd if=/dev/zero of=${partition} bs=1M count=1 2> /dev/null || true
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

	sgdisk -n 1:${BOOTLOAD_RESERVE}M:+${DTBO_ROM_SIZE}M -c 1:"dtbo_a"      -t 1:8300  $node
	sgdisk -n 2:0:+${DTBO_ROM_SIZE}M                    -c 2:"dtbo_b"      -t 2:8300  $node
	sgdisk -n 3:0:+${BOOT_ROM_SIZE}M                    -c 3:"boot_a"      -t 1:8300  $node
	sgdisk -n 4:0:+${BOOT_ROM_SIZE}M                    -c 4:"boot_b"      -t 2:8300  $node
	sgdisk -n 5:0:+${SYSTEM_ROM_SIZE}M                  -c 5:"system_a"    -t 3:8300  $node
	sgdisk -n 6:0:+${SYSTEM_ROM_SIZE}M                  -c 6:"system_b"    -t 4:8300  $node
	sgdisk -n 7:0:+${MISC_SIZE}M                        -c 7:"misc"        -t 5:8300  $node
	sgdisk -n 8:0:+${METADATA_SIZE}M                    -c 8:"metadata"    -t 6:8300  $node
	sgdisk -n 9:0:+${PRESISTDATA_SIZE}M                 -c 9:"presistdata" -t 7:8300  $node
	sgdisk -n 10:0:+${VENDOR_ROM_SIZE}M                 -c 10:"vendor_a"   -t 8:8300  $node
	sgdisk -n 11:0:+${VENDOR_ROM_SIZE}M                 -c 11:"vendor_b"   -t 9:8300  $node
	sgdisk -n 12:0:+${data_size}M                       -c 12:"userdata"   -t 10:8300 $node
	sgdisk -n 13:0:+${FBMISC_SIZE}M                     -c 13:"fbmisc"     -t 11:8300 $node
	sgdisk -n 14:0:+${VBMETA_SIZE}M                     -c 14:"vbmeta_a"   -t 12:8300 $node
	sgdisk -n 15:0:+${VBMETA_SIZE}M                     -c 15:"vbmeta_b"   -t 13:8300 $node

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
	dd if=/dev/zero of=${node}${part}9 bs=1M count=${PRESISTDATA_SIZE} conv=fsync
	blue_underlined_bold_echo "Erasing fbmisc partition"
	dd if=/dev/zero of=${node}${part}13 bs=1M count=${FBMISC_SIZE} conv=fsync
	blue_underlined_bold_echo "Erasing misc partition"
	dd if=/dev/zero of=${node}${part}7 bs=1M count=${MISC_SIZE} conv=fsync
	blue_underlined_bold_echo "Erasing metadata partition"
	dd if=/dev/zero of=${node}${part}8 bs=1M count=${METADATA_SIZE} conv=fsync
	blue_underlined_bold_echo "Formating userdata partition"
	mkfs.ext4 -F ${node}${part}12 -Ldata
	sync; sleep 1
}

function install_android
{
	echo
	blue_underlined_bold_echo "Installing Android dtbo image: $dtboimage_file"
	dd if=${imagesdir}/${dtboimage_file} of=${node}${part}1
	dd if=${imagesdir}/${dtboimage_file} of=${node}${part}2
	sync

	echo
	blue_underlined_bold_echo "Installing Android boot image: $bootimage_file"
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}3
	dd if=${imagesdir}/${bootimage_file} of=${node}${part}4
	sync

	echo
	blue_underlined_bold_echo "Installing Android system image: $systemimage_file"
	simg2img ${imagesdir}/${systemimage_file} ${node}${part}5
	simg2img ${imagesdir}/${systemimage_file} ${node}${part}6
	sync;

	echo
	blue_underlined_bold_echo "Installing Android vendor image: $vendorimage_file"
	simg2img ${imagesdir}/${vendorimage_file} ${node}${part}10
	simg2img ${imagesdir}/${vendorimage_file} ${node}${part}11
	sync;

	echo
	blue_underlined_bold_echo "Installing Android vbmeta image: $vbmeta_file"
	dd if=${imagesdir}/${vbmeta_file} of=${node}${part}14
	dd if=${imagesdir}/${vbmeta_file} of=${node}${part}15
	sync;

	sleep 1
}

function finish
{
	echo
	errors=0
	for partition in ${node}*
	do
		if [[ ! -b ${partition} ]] ; then
			red_bold_echo "ERROR: \"${partition}\" is not a block device"
			errors=$((errors+1))
		fi
	done

	if [[ ${errors} = 0 ]] ; then
		blue_bold_echo "Android installed successfully"
	else
		red_bold_echo "Android installation failed"
	fi
	exit ${errors}
}

stop_udev()
{
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl -q mask --runtime systemd-udevd
		systemctl -q stop systemd-udevd
	fi
}

start_udev()
{
	if [ -f /lib/systemd/system/systemd-udevd.service ]; then
		systemctl -q unmask --runtime systemd-udevd
		systemctl -q start systemd-udevd
	fi
}

check_images

umount ${node}${part}*  2> /dev/null || true

stop_udev
delete_device
create_parts
install_bootloader
format_android
install_android
start_udev
finish
