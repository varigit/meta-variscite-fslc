# Power up WIFI chip
wifi_up()
{
	# WIFI_PWR up
	echo 1 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
	usleep 10000

	# WLAN_EN up
	echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_EN up
	echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

	# BT_BUF up
	echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
	
	# Wait 150ms at least
	usleep 200000
	
	# BT_BUF down
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# BT_EN down
	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	
	# Bind WIFI device to MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/bind
	
	# Load WIFI driver
	modprobe brcmfmac

	# Load Ethernet driver
	modprobe fec
}

# Power down WIFI chip
wifi_down()
{
	# Unload WIFI driver
	modprobe -r brcmfmac

	# Unload Ethernet driver
	modprobe -r fec

	# Unbind WIFI device from MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind

	# WLAN_EN down
	echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_BUF down
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# BT_EN down
	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

	usleep 10000

	# WIFI power down
	echo 0 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
}

