#!/bin/sh

WIFI_MMC_HOST=2190000.usdhc
WIFI_SDIO_ID_FILE=/sys/bus/mmc/devices/mmc0:0001/mmc0:0001:1/device
WIFI_5G_SDIO_ID=0x4339

som_is_dart_6ul_5g()
{
   if [ ! -f ${WIFI_SDIO_ID_FILE} ]; then
     return 1
   fi

   WIFI_SDIO_ID=`cat ${WIFI_SDIO_ID_FILE}`
   if [ "${WIFI_SDIO_ID}" != "${WIFI_5G_SDIO_ID}"  ]; then
     return 1
   fi

   return 0
}

wifi_suspend() {
   if ! som_is_dart_6ul_5g; then
     exit 0
   fi

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

