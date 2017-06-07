#@DESCRIPTION: Linux for Variscite i.MX boards
#
# http://www.variscite.com

require recipes-kernel/linux/linux-imx.inc
require recipes-kernel/linux/linux-dtb.inc

DEPENDS += "lzop-native bc-native"

SRCBRANCH = "imx-rel_imx_4.1.15_2.0.0_ga-var02"

LOCALVERSION_var-som-mx6 = "-6qp"
LOCALVERSION_imx6ul-var-dart = "-6ul"
LOCALVERSION_imx7-var-som = "-7dual"

SRCREV = "2f50a8580a23faea3108d6cc15a052983b047640"
KERNEL_SRC ?= "git://github.com/varigit/linux-2.6-imx.git;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

DEFAULT_PREFERENCE = "1"

KERNEL_DEFCONFIG_var-som-mx6 = "${S}/arch/${ARCH}/configs/imx_v7_var_defconfig"
KERNEL_DEFCONFIG_imx6ul-var-dart = "${S}/arch/${ARCH}/configs/imx6ul-var-dart_defconfig"
KERNEL_DEFCONFIG_imx7-var-som = "${S}/arch/${ARCH}/configs/imx7-var-som_defconfig"

COMPATIBLE_MACHINE = "(var-som-mx6|imx6ul-var-dart|imx7-var-som)"
