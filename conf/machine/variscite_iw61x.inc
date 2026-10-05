MACHINE_EXTRA_RDEPENDS += " \
	kernel-module-nxp-wlan \
	linux-firmware-nxp-common \
	linux-firmware-nxpiw612-sdio \
	bcm43xx-utils-iw61x \
"

# Default network manager package configuration for bcm43xx-utils-iw61x:
# Match distro defaults: NetworkManager for Wayland, ConnMan otherwise
PACKAGECONFIG_pn-bcm43xx-utils ?= "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'networkmanager', 'connman', d)}"
