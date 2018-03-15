#@DESCRIPTION: Linux for Variscite i.MX boards
#
# http://www.variscite.com

require recipes-kernel/linux/linux-imx.inc
require recipes-kernel/linux/linux-dtb.inc

DEPENDS += "lzop-native bc-native"

# Do not copy the kernel image to the rootfs by default
RDEPENDS_kernel-base = ""

LOCALVERSION_var-som-mx6 = "-mx6"
LOCALVERSION_imx6ul-var-dart = "-mx6ul"
LOCALVERSION_imx7-var-som = "-mx7"

SRCBRANCH = "imx-rel_imx_4.1.15_2.0.0_ga-var02"
SRCBRANCH_imx6ul-var-dart = "imx-rel_imx_4.1.15_2.0.0_ga-var03"
SRCREV = "2c83fe7c93ae1720578c70896009eb7ebc810a62"
SRCREV_imx6ul-var-dart = "ab888e61c5676a8cb56a13e31b9470a1eb550986"
KERNEL_SRC ?= "git://github.com/varigit/linux-2.6-imx.git;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

DEFAULT_PREFERENCE = "1"

KERNEL_DEFCONFIG_var-som-mx6 = "${S}/arch/arm/configs/imx_v7_var_defconfig"
KERNEL_DEFCONFIG_imx6ul-var-dart = "${S}/arch/arm/configs/imx6ul-var-dart_defconfig"
KERNEL_DEFCONFIG_imx7-var-som = "${S}/arch/arm/configs/imx7-var-som_defconfig"

do_preconfigure_prepend() {
   cp ${KERNEL_DEFCONFIG} ${WORKDIR}/defconfig
}

do_configure_prepend_imx6ul-var-dart() {
   # Disable WIFI support, relevant code is built from external tree
   kernel_conf_variable CFG80211 n
}

do_configure_prepend_imx7-var-som() {
   # Disable WIFI support, relevant code is built from external tree
   kernel_conf_variable CFG80211 n
}

COMPATIBLE_MACHINE = "(var-som-mx6|imx6ul-var-dart|imx7-var-som)"
