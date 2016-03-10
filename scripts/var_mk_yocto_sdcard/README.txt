How to use the build SDCARD utility:
====================================

This utility is provided on an "AS IS" basis.
It is a part of a larger script we use to create our NAND-Recovery SD-card, which also includes Android.
It is a good example for using the output of the Yocto build to create a bootable sdcard, and use it to flash the target flash/eMMC.


Usage: 
cd ~/var-som-mx6-fido/build_x11
sudo ../sources/meta-variscite-mx6/scripts/var_mk_yocto_sdcard/var-create-yocto-sdcard.sh <options> /dev/sdX
(Change /dev/sdX to your device name)

options:
  -h            Display help message
  -s            Only show partition sizes to be written, without actually write them
  -a            Automatically set the rootfs partition size to fill the SD-card

If you don't use the '-a' option, a default rootfs size of 3700MiB will be used


Once the script is done, use the SD-card to boot, and then to flash your internal storage/s either use the icons,
or the following commands in command prompt:
yocto_emmc
yocto_nand


Enjoy.

Send any comments to support@variscite.com
