How to use the build SDCARD utility:
====================================


This utility is provided on a "AS IS" basis.
It is part of larger script we use to create our nand-recovery sdcard.
It is a good example for how to use the output of the Yocto build to create a bootable sdcard and to use it to flash the target flash/eMMC.
we flash the fsl-image-qt5-minimal
You can switch to fsl-image-qt5 it will be without ubifs.


cd ~/var-som-mx6-fido/build_x11
sudo ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh /dev/sdX
change /dev/sdX to your device name

Boot and use the icons.

Command line mode:
yocto_emmc
yocto_nand
yocto_dart


Enjoy.

Send any comments to ron.d@variscite.com, eran.m@variscite.com or support@variscite.com

