# Check is SOM is DART-6UL-5G
som_is_dart_6ul_5g()
{
	SOM_INFO=`i2cget -y 1 0x51 0xfd`
	if [[ $(($(($SOM_INFO >> 3)) & 0x3)) == 1 ]] ; then
		return 0
	fi

	return 1
}

# Setup WIFI control GPIOs
wifi_pre_up()
{
	if [ ! -d /sys/class/gpio/gpio${WIFI_EN_GPIO} ]; then
		echo ${WIFI_EN_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_EN_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${BT_EN_GPIO} ]; then
		echo ${BT_EN_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${BT_EN_GPIO}/direction
	fi

	if som_is_dart_6ul_5g; then
		if [ ! -d /sys/class/gpio/gpio${WIFI_PWR_GPIO} ]; then
			echo ${WIFI_PWR_GPIO} > /sys/class/gpio/export
			echo out > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/direction
		fi
	fi
}

# Power up WIFI chip
wifi_up()
{
	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
		echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
	fi

	if som_is_dart_6ul_5g; then
		# WIFI power up
		echo 1 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
		usleep 10000

		# WLAN_EN up
		echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN up
		echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	
		# Wait 150ms at least
		usleep 200000
	
		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	else
		# WLAN_EN up
		echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN up
		echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	
		# Wait 150ms at least
		usleep 200000
	
		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	fi
	
	# Bind WIFI device to MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/bind

	# Load WIFI driver
	modprobe brcmfmac
}

# Power down WIFI chip
wifi_down()
{
	# Unload WIFI driver
	modprobe -r brcmfmac

	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
		echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
	fi

	if som_is_dart_6ul_5g; then
		# WLAN_EN down
		echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
		usleep 10000

		# WIFI power down
		echo 0 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
	else
		# WLAN_EN down
		echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	fi
}

# Return true if WIFI should be started
wifi_should_not_be_started()
{
	# Do not enable WIFI if it is already up
	[ -d /sys/class/net/wlan0 ] && return 0

	# Do not enable WIFI if booting from SD          
	if grep -q mmcblk0 /proc/cmdline; then
		return 0
	fi

	# Exit if booting from eMMC without WIFI
	if ! grep -qi WIFI /sys/devices/soc0/machine; then
		return 0
	fi

	return 1
}

# Return true if WIFI should not be stopped
wifi_should_not_be_stopped()
{
	# Do not stop WIFI if booting from SD
	if grep -q mmcblk0 /proc/cmdline; then
		return 0
	fi

	# Do not stop WIFI if booting from eMMC without WIFI
	if ! grep -qi WIFI /sys/devices/soc0/machine; then
		return 0
	fi

	return 1
}
