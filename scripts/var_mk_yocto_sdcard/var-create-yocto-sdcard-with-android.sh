#!/bin/bash
set -e

YOCTO_ROOT=~/var-som-mx6-yocto-fido
YOCTO_BUILD=build_x11

ANDROID_500_ROOT=~/var_ll_511_210/ll_511_210_build
ANDROID_IMGS_PATH=out/target/product/var_mx6
ANDROID_SCRIPTS_PATH=./variscite_scripts_android

TEMP_DIR=./var_tmp
P1_MOUNT_DIR=${TEMP_DIR}/BOOT-VAR-SOM
P2_MOUNT_DIR=${TEMP_DIR}/rootfs

cd ${YOCTO_ROOT}/${YOCTO_BUILD}
../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh "$@"
cd -

# Parse command line only to get ${node} and ${part}
moreoptions=1
node="na"
cal_only=0

while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
        case $1 in
            -h) ;;
            -s) ;;
            -a) ;;
            *)  moreoptions=0; node=$1 ;;
        esac
        [ "$moreoptions" = 1 ] && shift
done

part=""
if [ `echo ${node} | grep -c mmcblk` -ne 0 ]; then
        part="p"
fi

echo "=========================================================="
echo "= Variscite build recovery SD-card V50 utility - Android ="
echo "=========================================================="

function copy_android
{
	mkdir -p ${P2_MOUNT_DIR}/opt/images/Android/Emmc

	echo "Copying Android to /opt/images/"
	cp ${ANDROID_500_ROOT}/${ANDROID_IMGS_PATH}/boot*.img		${P2_MOUNT_DIR}/opt/images/Android/Emmc/
	cp ${ANDROID_500_ROOT}/${ANDROID_IMGS_PATH}/recovery*.img	${P2_MOUNT_DIR}/opt/images/Android/Emmc/
	pv ${ANDROID_500_ROOT}/${ANDROID_IMGS_PATH}/system.img >	${P2_MOUNT_DIR}/opt/images/Android/Emmc/system.img
	cp ${ANDROID_500_ROOT}/${ANDROID_IMGS_PATH}/u-boot-var-imx6-nand.img	${P2_MOUNT_DIR}/opt/images/Android/Emmc/
	cp ${ANDROID_500_ROOT}/${ANDROID_IMGS_PATH}/u-boot-var-imx6-sd.img	${P2_MOUNT_DIR}/opt/images/Android/Emmc/u-boot-var-imx6-mmc.img
}

function copy_android_scripts
{
	echo "Copying Android scripts"
	cp ${ANDROID_SCRIPTS_PATH}/android-emmc.sh	${P2_MOUNT_DIR}/sbin/
	cp ${ANDROID_SCRIPTS_PATH}/mkmmc_android.sh	${P2_MOUNT_DIR}/sbin/

	echo "Copying Android desktop icon"
	cp ${ANDROID_SCRIPTS_PATH}/android_emmc.desktop	${P2_MOUNT_DIR}/usr/share/applications/ 
	cp ${ANDROID_SCRIPTS_PATH}/terminalae		${P2_MOUNT_DIR}/usr/bin/
}


# Mount the partitions
mkdir -p ${P1_MOUNT_DIR}
mkdir -p ${P2_MOUNT_DIR}
sync
mount ${node}${part}1  ${P1_MOUNT_DIR}
mount ${node}${part}2  ${P2_MOUNT_DIR}

copy_android
copy_android_scripts

echo "Syncing"
sync | pv -t
umount ${P1_MOUNT_DIR}
umount ${P2_MOUNT_DIR}
rm -rf ${TEMP_DIR}
echo "Done"
exit 0
