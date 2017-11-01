#@DESCRIPTION: Linux for Variscite i.MX boards
#
# http://www.variscite.com

require recipes-kernel/linux/linux-imx.inc

DEPENDS += "lzop-native bc-native"

# Do not copy the kernel image to the rootfs by default
RDEPENDS_kernel-base = ""

LOCALVERSION_var-som-mx6 = "-mx6"
LOCALVERSION_imx6ul-var-dart = "-mx6ul"
LOCALVERSION_imx7-var-som = "-mx7"

SRCBRANCH = "imx_4.9.11_1.0.0_ga-var01"
SRCREV = "d5615ea8aaa5560311a5c967c64068232365141b"
KERNEL_SRC ?= "git://github.com/varigit/linux-imx.git;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

DEFAULT_PREFERENCE = "1"

KERNEL_DEFCONFIG = "${S}/arch/arm/configs/imx_v7_var_defconfig"

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
