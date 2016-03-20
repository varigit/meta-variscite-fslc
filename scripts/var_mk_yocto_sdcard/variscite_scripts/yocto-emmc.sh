#!/bin/sh -e
#
# Variscite Yocto flash
#
echo "Yocto eMMC flash"
/bin/sh /sbin/nand-recovery.sh -o Yocto -m Emmc
read -p "Yocto Flashed. Press any key to continue... " -n1
exit 0
