How to use the Variscite SD card creation script:
=================================================

This utility is provided on an "AS IS" basis.
It is a part of a larger script we use to create our recovery SD card, which also includes Android.
It is a good example for using the output of the Yocto build to create a bootable SD card, and use it to flash the target NAND flash/eMMC.

Note:
Before running this script you need to bitbake fsl-image-gui.


Usage: 
sudo ./var-create-yocto-sdcard.sh <options> /dev/sdX
(Change /dev/sdX to your device name)

options:
  -h            Display help message
  -s            Only show partition sizes to be written, without actually write them
  -a            Automatically set the rootfs partition size to fill the SD card

If you don't use the '-a' option, a default rootfs size of 3700MiB will be used


Once the script is done, use the SD card to boot, and then to flash your internal storage/s either use the icons,
or the following linux shell script:
install_yocto.sh


Enjoy.

Send any comments to support@variscite.com
