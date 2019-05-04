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

ANDROID_SCRIPTS_PATH=${SCRIPT_POINT}/variscite_scripts
ANDROID_BUILD_ROOT=~/var_imx-p9.0.0_1.0.0-ga/android_build

TEMP_DIR=./var_tmp
ROOTFS_MOUNT_DIR=${TEMP_DIR}/rootfs

help() {
	bn=`basename $0`
	echo " Usage: MACHINE=<imx8m-var-dart|imx8mm-var-dart> $bn device_node"
	echo
}

case $MACHINE in
	"imx8m-var-dart")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/dart_mx8mq
		;;
	"imx8mm-var-dart")
		ANDROID_IMGS_PATH=${ANDROID_BUILD_ROOT}/out/target/product/dart_mx8mm
		;;
	*)
		help
		exit 1
esac

MACHINE=$MACHINE ${SCRIPT_POINT}/var-create-yocto-sdcard.sh "$@"

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
	mkdir -p ${ROOTFS_MOUNT_DIR}
	sync
	mount ${node}${part}1  ${ROOTFS_MOUNT_DIR}
}

function unmount_parts
{
	umount ${ROOTFS_MOUNT_DIR}
	rm -rf ${TEMP_DIR}
}

function copy_android
{
	echo
	echo "Copying Android images to /opt/images/"
	mkdir -p ${ROOTFS_MOUNT_DIR}/opt/images/Android

	cp ${ANDROID_IMGS_PATH}/u-boot-*.imx	${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/boot.img			${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/dtbo-*.img			${ROOTFS_MOUNT_DIR}/opt/images/Android/
	cp ${ANDROID_IMGS_PATH}/vbmeta-*.img			${ROOTFS_MOUNT_DIR}/opt/images/Android/

	echo "Copying system image to /opt/images/"
	pv ${ANDROID_IMGS_PATH}/system.img >		${ROOTFS_MOUNT_DIR}/opt/images/Android/system.img
	sync | pv -t
	echo "Copying vendor image to /opt/images/"
	pv ${ANDROID_IMGS_PATH}/vendor.img >		${ROOTFS_MOUNT_DIR}/opt/images/Android/vendor.img
	sync | pv -t
}

function copy_android_scripts
{
	echo
	echo "Copying Android script"
	cp ${ANDROID_SCRIPTS_PATH}/mx8_install_android.sh		${ROOTFS_MOUNT_DIR}/usr/bin/install_android.sh
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
