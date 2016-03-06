#!/bin/bash

# partition size in MB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=20
SPARE_SIZE=400


echo "Variscite Make Yocto Fido SDCARD utility version 02"
echo "==================================================="

#if [ ! -f uboot-imx/SPL ]
#then
#	echo "uboot-imx/SPL does not exist! exit."
#	exit 1
#fi	
#if [ ! -f uboot-imx/u-boot.img ]
#then
#	echo "uboot-imx/u-boot.img does not exist! exit."
#	exit 1
#fi	




help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h				displays this help message
  -s				only get partition size
EOF

}

# check the if root?
userid=`id -u`
if [ $userid -ne "0" ]; then
	echo "you're not root?"
	exit
fi


# parse command line
moreoptions=1
node="na"
cal_only=0


while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
	    -s) cal_only=1 ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

if [ ! -e ${node} ]; then
	help
	exit
fi

part=""
echo ${node} | grep mmcblk > /dev/null
if [ "$?" -eq "0" ]; then
	part="p"
fi

fdisk ${node} >/dev/null >>/dev/null <<EOF 
d
1
d
2
d
3
d
w
EOF

# call sfdisk to create partition table
# get total card size
seprate=40
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
rootfs_size=`expr ${total_size} - ${boot_rom_sizeb} - ${SPARE_SIZE} + ${seprate}`

# create partitions
if [ "${cal_only}" -eq "1" ]; then
cat << EOF
BOOT   : ${boot_rom_sizeb}MB
ROOT   : ${rootfs_size}MB
EOF
exit
fi

function format_yocto
{
    echo "formating yocto partitions"
    echo "=========================="
    mkfs.vfat ${node}${part}1 -nBOT-VAR-SOM
    mkfs.ext4 ${node}${part}2 -Lrootfs
}

function flash_yocto
{
    echo "flashing yocto "
    echo "==============="
    mkdir -p ./var_tmp/BOT-VAR-SOM
    mkdir -p ./var_tmp/rootfs
    sync
    ls -l ./var_tmp/BOT-VAR-SOM
    ls -l ./var_tmp/rootfs

    echo "flashing U-Boot ..."    
    sudo dd if=tmp/deploy/images/var-som-mx6/u-boot-sd-2015.10-r0.img of=${node} bs=1K seek=69; sync
    sudo dd if=tmp/deploy/images/var-som-mx6/SPL-sd of=${node} bs=1K seek=1; sync

    echo "flashing Yocto BOOT partition ..."    
    sync
    mount ${node}${part}1  ./var_tmp/BOT-VAR-SOM
    cp tmp/deploy/images/var-som-mx6/uImage-imx6q-var-som.dtb		 	./var_tmp/BOT-VAR-SOM/imx6q-var-som.dtb
    cp tmp/deploy/images/var-som-mx6/uImage-imx6dl-var-som.dtb			./var_tmp/BOT-VAR-SOM/imx6dl-var-som.dtb
    cp tmp/deploy/images/var-som-mx6/uImage-imx6q-var-som-vsc.dtb		./var_tmp/BOT-VAR-SOM/imx6q-var-som-vsc.dtb
    cp tmp/deploy/images/var-som-mx6/uImage-imx6dl-var-som-solo.dtb		./var_tmp/BOT-VAR-SOM/imx6dl-var-som-solo.dtb
    cp tmp/deploy/images/var-som-mx6/uImage-imx6dl-var-som-solo-vsc.dtb		./var_tmp/BOT-VAR-SOM/imx6dl-var-som-solo-vsc.dtb
    cp tmp/deploy/images/var-som-mx6/uImage-imx6q-var-dart.dtb		 	./var_tmp/BOT-VAR-SOM/imx6q-var-dart.dtb
    cp tmp/deploy/images/var-som-mx6/uImage					./var_tmp/BOT-VAR-SOM/uImage

    echo "flashing Yocto Root file System ..."    
    sync
    mount ${node}${part}2  ./var_tmp/rootfs
    tar xf tmp/deploy/images/var-som-mx6/fsl-image-qt5-var-som-mx6.tar.bz2 -C ./var_tmp/rootfs/ 

}

function copy_yocto
{
sudo mkdir -p ./var_tmp/rootfs/opt
sudo mkdir -p ./var_tmp/rootfs/opt/images
sudo mkdir -p ./var_tmp/rootfs/opt/images/Yocto
sudo mkdir -p ./var_tmp/rootfs/opt/images/Android
sudo mkdir -p ./var_tmp/rootfs/opt/images/Android/Emmc
#
echo "Copying Fido V10.1 /opt/images/Yocto..."
sudo cp tmp/deploy/images/var-som-mx6/uImage 					./var_tmp/rootfs/opt/images/Yocto
sudo cp tmp/deploy/images/var-som-mx6/fsl-image-qt5-var-som-mx6.tar.bz2 	./var_tmp/rootfs/opt/images/Yocto/rootfs.tar.bz2
sudo cp tmp/deploy/images/var-som-mx6/fsl-image-qt5-minimal-var-som-mx6.ubi 	./var_tmp/rootfs/opt/images/Yocto/rootfs.ubi.img
#
sudo cp tmp/deploy/images/var-som-mx6/uImage-imx6dl-var-som-solo.dtb 		./var_tmp/rootfs/opt/images/Yocto/
sudo cp tmp/deploy/images/var-som-mx6/uImage-imx6dl-var-som-solo-vsc.dtb 	./var_tmp/rootfs/opt/images/Yocto/
sudo cp tmp/deploy/images/var-som-mx6/uImage-imx6dl-var-som.dtb 		./var_tmp/rootfs/opt/images/Yocto/
sudo cp tmp/deploy/images/var-som-mx6/uImage-imx6q-var-som.dtb 			./var_tmp/rootfs/opt/images/Yocto/
sudo cp tmp/deploy/images/var-som-mx6/uImage-imx6q-var-som-vsc.dtb 		./var_tmp/rootfs/opt/images/Yocto/
sudo cp tmp/deploy/images/var-som-mx6/uImage-imx6q-var-dart.dtb 		./var_tmp/rootfs/opt/images/Yocto/
echo "nand u-boot..."
sudo cp tmp/deploy/images/var-som-mx6/SPL-nand					./var_tmp/rootfs/opt/images/Yocto/SPL
sudo cp tmp/deploy/images/var-som-mx6/u-boot-nand-2015.10-r0.img		./var_tmp/rootfs/opt/images/Yocto/u-boot.img
echo "sd u-boot..."
sudo cp tmp/deploy/images/var-som-mx6/SPL-sd					./var_tmp/rootfs/opt/images/Yocto/SPL.mmc
sudo cp tmp/deploy/images/var-som-mx6/u-boot-sd-2015.10-r0.img			./var_tmp/rootfs/opt/images/Yocto/u-boot.img.mmc
}

function copy_scripts
{
echo "scripts..."
sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/nand-recovery.sh 	./var_tmp/rootfs/sbin/
#sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/android-nand.sh  	./var_tmp/rootfs/sbin/
#sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/android-emmc.sh  	./var_tmp/rootfs/sbin/
sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/yocto-nand.sh    	./var_tmp/rootfs/sbin/
sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/yocto-emmc.sh    	./var_tmp/rootfs/sbin/
sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/yocto-dart.sh	./var_tmp/rootfs/sbin/
#
#sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/mkmmc_android.sh 	./var_tmp/rootfs/sbin/
sudo cp  ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/mkmmc_yocto.sh    	./var_tmp/rootfs/sbin/

echo "desktop icons..."
sudo cp ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/*.desktop      	./var_tmp/rootfs/usr/share/applications/ 
sudo cp ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/variscite_scripts/terminal*      	./var_tmp/rootfs/usr/bin
}

# destroy the partition table
dd if=/dev/zero of=${node} bs=1024 count=1

sfdisk --force -uM ${node} << EOF
,${boot_rom_sizeb},b
,${rootfs_size},83
EOF

# adjust the partition reserve for bootloader.
# if you don't put the uboot on same device, you can remove the BOOTLOADER_ERSERVE
# to have 8M space.
# the minimal sylinder for some card is 4M, maybe some was 8M
# just 8M for some big eMMC 's sylinder
sfdisk --force -uM ${node} -N1 << EOF
${BOOTLOAD_RESERVE},${BOOT_ROM_SIZE},83
EOF

# format the SDCARD/DATA/CACHE partition
part=""
echo ${node} | grep mmcblk > /dev/null
if [ "$?" -eq "0" ]; then
	part="p"
fi

format_yocto
flash_yocto
copy_yocto
copy_scripts

echo "umount ..."
sync
sudo umount ./var_tmp/BOT-VAR-SOM
sudo umount ./var_tmp/rootfs

