#!/bin/sh

WIFI_MMC_HOST=2190000.usdhc
WIFI_MMC_DTS_DIR="/proc/device-tree/soc/aips-bus@02100000/usdhc@02190000"
WIFI_MMC_DTS_FILE="${WIFI_MMC_DTS_DIR}/no-1-8-v"

wifi_suspend() {
   echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
}

wifi_resume() {
   echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/bind
}

som_is_dart_6ul_5g()
{
  if [ -d ${WIFI_MMC_DTS_DIR} -a ! -f ${WIFI_MMC_DTS_FILE} ]; then
    return 0
  fi

  return 1
}

# Do nothing on DART-6UL
if ! som_is_dart_6ul_5g; then
  exit 0
fi

case $1 in

"suspend")
        wifi_suspend
        ;;
"resume")
        wifi_resume
        ;;
esac

