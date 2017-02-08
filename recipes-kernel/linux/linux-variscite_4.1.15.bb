#@DESCRIPTION: Linux for Variscite i.MX boards
#
# http://www.variscite.com

require recipes-kernel/linux/linux-imx.inc
require recipes-kernel/linux/linux-dtb.inc

DEPENDS += "lzop-native bc-native"

SRCBRANCH = "imx-rel_imx_4.1.15_2.0.0_ga-var01"

LOCALVERSION_var-som-mx6 = "-6QP"
LOCALVERSION_imx6ul-var-dart = "-6UL"
LOCALVERSION_imx7-var-som = "-7Dual"

SRCREV = "${AUTOREV}"
SRCREV_imx6ul-var-dart = "ce9d77cac56641cfbd1ce816492e7ad8a9950251"
KERNEL_SRC ?= "git://github.com/varigit/linux-2.6-imx.git;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

DEFAULT_PREFERENCE = "1"

KERNEL_DEFCONFIG_var-som-mx6 = "imx_v7_var_defconfig"
KERNEL_DEFCONFIG_imx6ul-var-dart = "imx6ul-var-dart_defconfig"
KERNEL_DEFCONFIG_imx7-var-som = "imx7-var-som_defconfig"

do_preconfigure_prepend() {
   cp ${S}/arch/arm/configs/${KERNEL_DEFCONFIG} ${B}/.config
   cp ${S}/arch/arm/configs/${KERNEL_DEFCONFIG} ${B}/../defconfig
}

do_configure_prepend() {
   # delete old .config from source code
   rm ${S}/.config || true
}

# Copy the config file required by ti-compat-wirless-wl18xx
do_deploy_append () {
   cp ${S}/arch/arm/configs/${KERNEL_DEFCONFIG} ${S}/.config
}

COMPATIBLE_MACHINE = "(var-som-mx6|imx6ul-var-dart|imx7-var-som)"
