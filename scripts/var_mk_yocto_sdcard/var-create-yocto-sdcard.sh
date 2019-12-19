#!/bin/bash
set -e

#### Script version ####
SCRIPT_NAME=${0##*/}
readonly SCRIPT_VERSION="0.7"

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=`readlink -e "$0"`
readonly ABSOLUTE_DIRECTORY=`dirname ${ABSOLUTE_FILENAME}`
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}

readonly YOCTO_ROOT="${SCRIPT_POINT}/../../../.."

if [[ -e ${YOCTO_ROOT}/b2qt-init-build-env ]] ; then
	readonly BSP_TYPE="B2QT"
	readonly YOCTO_BUILD=${YOCTO_ROOT}/build-${MACHINE}
	readonly YOCTO_DEFAULT_IMAGE=b2qt-embedded-qt5-image
else
	readonly BSP_TYPE="YOCTO"
	readonly YOCTO_BUILD=${YOCTO_ROOT}/build_xwayland
	readonly YOCTO_DEFAULT_IMAGE=fsl-image-gui
fi
echo "BSP type: ${BSP_TYPE}"

readonly YOCTO_SCRIPTS_PATH=${SCRIPT_POINT}/variscite_scripts
readonly YOCTO_IMGS_PATH=${YOCTO_BUILD}/tmp/deploy/images/${MACHINE}

# Sizes are in MiB
BOOTLOAD_RESERVE_SIZE=8
DEFAULT_ROOTFS_SIZE=3800
BOOTLOADER_OFFSET=33

AUTO_FILL_SD=0
SPARE_SIZE=4
LOOP_MAJOR=7

# This function performs sanity check to verify  that the target device is removable devise of proper size
function check_device()
{
	# Check that parameter is a valid block device
	if [ ! -b "$1" ]; then
          echo "$1 is not a valid block device, exiting"
	  exit 1
        fi

	local dev=$(basename $1)

	# Check that /sys/block/$dev exists
	if [ ! -d /sys/block/$dev ]; then
	  echo "Directory /sys/block/${dev} missing, exiting"
	  exit 1
        fi

	# Get device parameters
	local removable=$(cat /sys/block/${dev}/removable)
	local size_bytes=$((512*$(cat /sys/class/block/${dev}/size)))
	local size_gb=$((size_bytes/1000000000))

	# Non-removable SD card readers require additional check
	if [ "${removable}" != "1" ]; then
          local drive=$(udisksctl info -b /dev/${dev}|grep "Drive:"|cut -d"'" -f 2)
          local mediaremovable=$(gdbus call --system --dest org.freedesktop.UDisks2 \
				  --object-path ${drive} --method org.freedesktop.DBus.Properties.Get \
				  org.freedesktop.UDisks2.Drive MediaRemovable)
	  if [[ "${mediaremovable}" = *"true"* ]]; then
	    removable=1
	  fi
	fi

	# Check that device is either removable or loop
	if [ "$removable" != "1" -a $(stat -c '%t' /dev/$dev) != ${LOOP_MAJOR} ]; then
          echo "$1 is not a removable device, exiting"
	  exit 1
        fi

	# Check that device is attached
	if [ ${size_bytes} -eq 0 ]; then
          echo "$1 is not attached, exiting"
          exit 1
	fi

	# Check that device has a valid size
	echo "Detected removable device $1, size=${size_gb}GB"
}

YOCTO_RECOVERY_ROOTFS_PATH=${YOCTO_IMGS_PATH}
YOCTO_RECOVERY_ROOTFS_BASE_IN_NAME=${YOCTO_DEFAULT_IMAGE}-${MACHINE}

echo "================================================"
echo "=  Variscite recovery SD card creation script  ="
echo "================================================"

help() {
	bn=`basename $0`
	echo " Usage: MACHINE=<imx8mq-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qm-var-som> $bn <options> device_node"
	echo
	echo " options:"
	echo " -h		display this Help message"
	echo " -s		only Show partition sizes to be written, without actually write them"
	echo " -a		Automatically set the rootfs partition size to fill the SD card (leaving spare ${SPARE_SIZE}MiB)"
	echo " -r ROOTFS_NAME	select an alternative Rootfs for recovery images"
	echo " 		(default: \"${YOCTO_RECOVERY_ROOTFS_PATH}/${YOCTO_DEFAULT_IMAGE}-\${MACHINE}\")"
	echo " -n TEXT_FILE	add a release Notes text file"
	echo
}

if [[ $EUID -ne 0 ]] ; then
	echo "This script must be run with super-user privileges"
	exit 1
fi

if [[ $MACHINE != "imx8mq-var-dart" && $MACHINE != "imx8mm-var-dart" && \
      $MACHINE != "imx8qxp-var-som" && $MACHINE != "imx8qm-var-som" ]] ; then
	help
	exit 1
fi

if [[ $MACHINE = "imx8qxp-var-som" || $MACHINE = "imx8qm-var-som" ]]; then
	BOOTLOADER_OFFSET=32
fi

TEMP_DIR=./var_tmp
P1_MOUNT_DIR=${TEMP_DIR}/${FAT_VOLNAME}
P2_MOUNT_DIR=${TEMP_DIR}/rootfs


# Parse command line
moreoptions=1
node="na"
cal_only=0

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit 3 ;;
	    -s) cal_only=1 ;;
	    -a) AUTO_FILL_SD=1 ;;
	    -r) shift;
			YOCTO_RECOVERY_ROOTFS_MASK_PATH=`readlink -e "${1}.tar.gz"`;
			YOCTO_RECOVERY_ROOTFS_PATH=`dirname ${YOCTO_RECOVERY_ROOTFS_MASK_PATH}`
			YOCTO_RECOVERY_ROOTFS_BASE_IN_NAME=`basename ${1}`
	    ;;
	    -n) shift;
			RELEASE_NOTES_FILE=${1}
	    ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit 1
	[ "$moreoptions" = 1 ] && shift
done
part=""
if [[ $node == *mmcblk* ]] || [[ $node == *loop* ]] ; then
	part="p"
fi

# allow only removable/loopback devices, to protect host PC
echo "MACHINE=${MACHINE}"
echo "SD card rootfs:  ${YOCTO_DEFAULT_IMAGE}-${MACHINE}"
echo "Recovery rootfs: ${YOCTO_RECOVERY_ROOTFS_BASE_IN_NAME}"
echo "================================================"
check_device $node
echo "================================================"
read -p "Press Enter to continue"

# Call sfdisk to get total card size
if [ "${AUTO_FILL_SD}" -eq "1" ]; then
	TOTAL_SIZE=`sfdisk -s ${node}`
	TOTAL_SIZE=`expr ${TOTAL_SIZE} / 1024`
	ROOTFS_SIZE=`expr ${TOTAL_SIZE} - ${BOOTLOAD_RESERVE_SIZE} - ${SPARE_SIZE}`
else
	ROOTFS_SIZE=${DEFAULT_ROOTFS_SIZE}
fi

if [ "${cal_only}" -eq "1" ]; then
cat << EOF
BOOTLOADER (No Partition) : ${BOOTLOAD_RESERVE_SIZE}MiB
ROOT-FS                   : ${ROOTFS_SIZE}MiB
EOF
exit 3
fi


function delete_device
{
	echo
	echo "Deleting current partitions"
	for ((i=0; i<=10; i++))
	do
		if [[ -e ${node}${part}${i} ]] ; then
			dd if=/dev/zero of=${node}${part}${i} bs=512 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	dd if=/dev/zero of=$node bs=1M count=${BOOTLOAD_RESERVE_SIZE}
	sync; sleep 1
}

function ceildiv
{
    local num=$1
    local div=$2
    echo $(( (num + div - 1) / div ))
}

function create_parts
{
	echo
	echo "Creating new partitions"
	BLOCK=`echo ${node} | cut -d "/" -f 3`
	SECT_SIZE_BYTES=`cat /sys/block/${BLOCK}/queue/physical_block_size`

	BOOTLOAD_RESERVE_SIZE_BYTES=$((BOOTLOAD_RESERVE_SIZE * 1024 * 1024))
	ROOTFS_SIZE_BYTES=$((ROOTFS_SIZE * 1024 * 1024))

	PART1_START=`ceildiv ${BOOTLOAD_RESERVE_SIZE_BYTES} ${SECT_SIZE_BYTES}`
	PART1_SIZE=`ceildiv ${ROOTFS_SIZE_BYTES} ${SECT_SIZE_BYTES}`

sfdisk --force -uS ${node} &> /dev/null << EOF
${PART1_START},${PART1_SIZE},83
EOF

	sync; sleep 1
	fdisk -l $node
}

function format_parts
{
	echo
	echo "Formatting partitions"
	mkfs.ext4 ${node}${part}1 -L rootfs
	sync; sleep 1
}

function install_bootloader
{
	echo
	echo "Installing U-Boot"
	dd if=${YOCTO_IMGS_PATH}/imx-boot-${MACHINE}-sd.bin of=${node} bs=1K seek=${BOOTLOADER_OFFSET}; sync
}

function mount_parts
{
	mkdir -p ${P2_MOUNT_DIR}
	sync
	mount ${node}${part}1  ${P2_MOUNT_DIR}
}

function unmount_parts
{
	umount ${P2_MOUNT_DIR}
	rm -rf ${TEMP_DIR}
}

function install_yocto
{
	echo
	echo "Installing Yocto Root File System"
	pv ${YOCTO_IMGS_PATH}/${YOCTO_DEFAULT_IMAGE}-${MACHINE}.tar.gz | tar -xz -C ${P2_MOUNT_DIR}/
	sync
}

function copy_images
{
	echo
	echo "Copying Yocto images to /opt/images/"
	mkdir -p ${P2_MOUNT_DIR}/opt/images/Yocto

	# Copy image for eMMC
	if [ -f ${YOCTO_RECOVERY_ROOTFS_PATH}/${YOCTO_RECOVERY_ROOTFS_BASE_IN_NAME}.tar.gz ]; then
		pv ${YOCTO_RECOVERY_ROOTFS_PATH}/${YOCTO_RECOVERY_ROOTFS_BASE_IN_NAME}.tar.gz > ${P2_MOUNT_DIR}/opt/images/Yocto/rootfs.tar.gz
	else
		echo "rootfs.tar.gz file is not present. Installation on \"eMMC\" will not be supported."
	fi

	if [ ${MACHINE} = "imx8mq-var-dart" ]; then
		cp ${YOCTO_RECOVERY_ROOTFS_PATH}/imx-boot-${MACHINE}-sd.bin-* ${P2_MOUNT_DIR}/opt/images/Yocto
		(cd ${P2_MOUNT_DIR}/opt/images/Yocto; ln -fs imx-boot-${MACHINE}-sd.bin-flash_evk imx-boot-sd.bin)
	else
		cp ${YOCTO_RECOVERY_ROOTFS_PATH}/imx-boot-${MACHINE}-sd.bin ${P2_MOUNT_DIR}/opt/images/Yocto/imx-boot-sd.bin
	fi
}

function copy_scripts
{
	echo
	echo "Copying scripts"

	cp ${YOCTO_SCRIPTS_PATH}/echos.sh 		${P2_MOUNT_DIR}/usr/bin/
	cp ${YOCTO_SCRIPTS_PATH}/mx8_install_yocto.sh	${P2_MOUNT_DIR}/usr/bin/install_yocto.sh
}

umount ${node}${part}*  2> /dev/null || true

delete_device
create_parts
format_parts

mount_parts
install_yocto
copy_images
copy_scripts

echo
echo "Syncing"
sync | pv -t

unmount_parts

install_bootloader

echo
echo "Done"

exit 0
