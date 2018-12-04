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

ANDROID_BUILD_ROOT=~/var_o_800_100/imx-o8.0.0_1.0.0_ga/android_build
ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/var_mx6
ANDROID_SCRIPTS_PATH=${SCRIPT_POINT}/variscite_scripts_android

TEMP_DIR=./var_tmp
P1_MOUNT_DIR=${TEMP_DIR}/BOOT-VAR-SOM
P2_MOUNT_DIR=${TEMP_DIR}/rootfs

if [[ $MACHINE != var-som-mx6 ]] ; then
	echo
	echo "Setting MACHINE=var-som-mx6"
	echo
fi

MACHINE=var-som-mx6 ${SCRIPT_POINT}/var-create-yocto-sdcard.sh "$@"

# Parse command line only to get ${node} and ${part}
moreoptions=1
node="na"
cal_only=0

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) ;;
	    -s) ;;
	    -a) ;;
	    -r) shift;
	    ;;
	    -n) shift;
	    ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 1 ] && shift
done

part=""
if [[ $node == *mmcblk* ]] || [[ $node == *loop* ]] ; then
	part="p"
fi

echo "========================================================"
echo "= Variscite recovery SD card creation script - Android ="
echo "========================================================"

function mount_parts
{
	mkdir -p ${P1_MOUNT_DIR}
	mkdir -p ${P2_MOUNT_DIR}
	sync
	mount ${node}${part}1  ${P1_MOUNT_DIR}
	mount ${node}${part}2  ${P2_MOUNT_DIR}
}

function unmount_parts
{
	umount ${P1_MOUNT_DIR}
	umount ${P2_MOUNT_DIR}
	rm -rf ${TEMP_DIR}
}

function copy_android
{
	echo
	echo "Copying Android images to /opt/images/"
	mkdir -p ${P2_MOUNT_DIR}/opt/images/Android

	cp ${ANDROID_IMGS_PATH}/boot-*.img			${P2_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/recovery-*.img			${P2_MOUNT_DIR}/opt/images/Android/

	cp ${ANDROID_IMGS_PATH}/u-boot-var-imx6-nand.img	${P2_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/u-boot-var-imx6-sd.img		${P2_MOUNT_DIR}/opt/images/Android/u-boot-var-imx6-mmc.img
	cp ${ANDROID_IMGS_PATH}/SPL-var-imx6-nand		${P2_MOUNT_DIR}/opt/images/Android/SPL-nand
	cp ${ANDROID_IMGS_PATH}/SPL-var-imx6-sd			${P2_MOUNT_DIR}/opt/images/Android/SPL-mmc

	echo "Creating system raw image"
	${ANDROID_BUILD_ROOT}/out/host/linux-x86/bin/simg2img	${ANDROID_IMGS_PATH}/system.img ${ANDROID_IMGS_PATH}/system_raw.img
	sync | pv -t
	echo "Creating vendor raw image"
	${ANDROID_BUILD_ROOT}/out/host/linux-x86/bin/simg2img	${ANDROID_IMGS_PATH}/vendor.img ${ANDROID_IMGS_PATH}/vendor_raw.img
	sync | pv -t
	gzip -9 ${ANDROID_IMGS_PATH}/system_raw.img
	gzip -9 ${ANDROID_IMGS_PATH}/vendor_raw.img
	echo "Copying system raw image to /opt/images/"
	pv ${ANDROID_IMGS_PATH}/system_raw.img.gz >		${P2_MOUNT_DIR}/opt/images/Android/system_raw.img.gz
	sync | pv -t
	echo "Copying vendor raw image to /opt/images/"
	pv ${ANDROID_IMGS_PATH}/vendor_raw.img.gz >		${P2_MOUNT_DIR}/opt/images/Android/vendor_raw.img.gz
	sync | pv -t
	echo "Removing system raw image"
	rm ${ANDROID_IMGS_PATH}/system_raw.img.gz
	echo "Removing vendor raw image"
	rm ${ANDROID_IMGS_PATH}/vendor_raw.img.gz
}

function copy_android_scripts
{
	echo
	echo "Copying Android scripts and desktop icons"
	cp ${ANDROID_SCRIPTS_PATH}/*.sh		${P2_MOUNT_DIR}/usr/bin/

	cp ${ANDROID_SCRIPTS_PATH}/*.desktop	${P2_MOUNT_DIR}/usr/share/applications/
}

mount_parts
copy_android
copy_android_scripts

echo
echo "Syncing"
sync | pv -t

unmount_parts

echo
echo "Done"

exit 0
