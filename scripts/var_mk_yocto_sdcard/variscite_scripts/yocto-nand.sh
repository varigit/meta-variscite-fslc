#!/bin/sh -e
#
# Variscite Yocto flash 
#
echo "Yocto NAND flash"
/bin/sh /sbin/nand-recovery.sh -o Yocto
read -p "Yocto Flashed. Press any key to continue... " -n1
exit 0
