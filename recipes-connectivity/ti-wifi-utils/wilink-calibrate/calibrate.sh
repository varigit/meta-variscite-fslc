#!/bin/sh
echo "Performing wifi calibration..."
rm /lib/firmware/ti-connectivity/wl1271-nvs.bin
rmmod wl12xx_sdio.ko
calibrator plt autocalibrate wlan0 /lib/modules/$(uname -r)/updates/drivers/net/wireless/wl12xx/wl12xx_sdio.ko /usr/share/ti/wifi-utils/ini_files/127x/TQS_S_2.6.ini /lib/firmware/ti-connectivity/wl1271-nvs.bin 00:00:00:00:00:00
modprobe wl12xx_sdio

