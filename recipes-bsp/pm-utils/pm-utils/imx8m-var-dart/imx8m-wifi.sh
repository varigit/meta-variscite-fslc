#!/bin/sh

WIFI_MMC_HOST=30b50000.usdhc

wifi_suspend() {
   echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
}

wifi_resume() {
   echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/bind
}

case $1 in

"suspend")
        wifi_suspend
        ;;
"resume")
        wifi_resume
        ;;
esac

