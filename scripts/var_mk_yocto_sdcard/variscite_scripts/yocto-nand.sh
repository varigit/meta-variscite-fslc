#!/bin/sh -e
#
# variscite Yocto flash 
#
echo "Yocto nand flash"
/bin/sh /sbin/nand-recovery.sh -o Yocto
read -p "Yocto Flashed. Press any key to continue... " -n1 -s
#
exit 0
