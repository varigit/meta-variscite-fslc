#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: $0 /dev/mmcblk1"
	exit -1 ;
fi
force='';

product=mx6;

echo $product
full_product=var_som_${product}
diskname=$1

if [[ "$diskname" =~ "mmcblk" ]]; then
   prefix=p
fi

echo "Creating Android SD-card on ${diskname} for product ${full_product}"

# partition size in MB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=8
SYSTEM_ROM_SIZE=512
CACHE_SIZE=512
RECOVERY_ROM_SIZE=8
VENDER_SIZE=8
MISC_SIZE=8
MEDIA=/opt/images/Yocto


help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h				displays this help message
  -c				only get partition size
  -solo				install IMX6 Solo U-Boot
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
node=$1

if [ `dmesg |grep VAR-DART | wc -l` = 1 ] ; then
	node=/dev/mmcblk2
	mmm=/run/media/mmcblk2p
else
	node=/dev/mmcblk1
	mmm=/run/media/mmcblk1p
fi

if [ ! -b ${node} ]; then
	echo "ERROR: \"${node}\" is not block device"
	exit
fi


umount ${mmm}1 2>/dev/null
umount ${mmm}2 2>/dev/null
umount ${mmm}3 2>/dev/null
umount ${mmm}4 2>/dev/null
umount ${mmm}5 2>/dev/null
umount ${mmm}6 2>/dev/null
umount ${mmm}7 2>/dev/null
umount ${mmm}8 2>/dev/null
umount ${mmm}9 2>/dev/null

#
# Delete all partitions
#
fdisk ${node} <<EOF
d
1
d
2
d
3
d
w
EOF

sync                       
#
#Delete MBR
#
dd if=/dev/zero of=${node} bs=512 count=1000
sync


# call sfdisk to create partition table
# get total card size
seprate=40
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`


function format_linux
{
    echo "formating linux partition on eMMC"
    mkfs.ext4 ${node}${prefix}1 -Lrootfs
}

function flash_linux
{
    echo "Installing rootfs on eMMC (this will take time)..."
    mkdir ${mmm}1
    mount ${node}${prefix}1  ${mmm}1
    tar xvpf ${MEDIA}/rootfs.tar.bz2 -C ${mmm}1/ 2>&1 |
    while read line; do
        x=$((x+1))
        echo -en "$x extracted\r"
    done
}

# destroy the partition table
#dd if=/dev/zero of=${node} bs=1024 count=1 conv=notrunc

sfdisk --force -uM ${node} << EOF
,${total_size},83
EOF
if [ "$?" = "0" ]; then
	sync
	sleep 4
else
	echo -e "\e[31msfdisk error #1! Partition is locked\e[0m"
	echo -e "\e[31mplease reboot to unlock and try again\e[0m"
	echo "==============================================="
	echo " "
	exit 1
fi

# format the SDCARD/DATA/CACHE partition
part=""
echo ${node} | grep mmcblk > /dev/null
if [ "$?" -eq "0" ]; then
	part="p"
fi

sync

format_linux
sync
flash_linux
sync
umount ${mmm}1 2>/dev/null
umount ${mmm}2 2>/dev/null
umount ${mmm}3 2>/dev/null
umount ${mmm}4 2>/dev/null
umount ${mmm}5 2>/dev/null
umount ${mmm}6 2>/dev/null
umount ${mmm}7 2>/dev/null
umount ${mmm}8 2>/dev/null
umount ${mmm}9 2>/dev/null

echo "========================================"
echo "Please stop at u-boot and set enviroment"
echo "setenv bootargs console=ttymxc0,115200 video=mxcfb1:off root=/dev/mmcblk1p1 rootwait rw"
echo "saveenv"
echo "========================================"
