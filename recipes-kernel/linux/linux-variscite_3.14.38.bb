#
#@DESCRIPTION: Linux for Variscite i.MX6Q/Dl/Solo VAR-SOM-MX6
#@MAINTAINER: Ron Donio <ron.d@variscite.com>
#
# http://www.variscite.com
# support@variscite.com
#
require recipes-kernel/linux/linux-imx.inc
require recipes-kernel/linux/linux-dtb.inc

DEPENDS += "lzop-native bc-native"

#SRC_URI = "git://github.com/varigit/linux-2.6-imx.git;protocol=git;branch=imx_3.14.28-r0_var3"


SRCBRANCH = "imx_3.14.38_6qp_ga_var01"
LOCALVERSION = "-6QP"
SRCREV = "04e862becc6cd1c6cac0c6c6305877ae4b0eac29"
KERNEL_SRC ?= "git://github.com/varigit/linux-2.6-imx.git;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"
#LOCALVERSION = "-1.1.0"

FSL_KERNEL_DEFCONFIG = "imx_v7_var_defconfig"

KERNEL_IMAGETYPE = "uImage"

KERNEL_EXTRA_ARGS += "LOADADDR=${UBOOT_ENTRYPOINT}"

do_configure_prepend() {
   # copy latest defconfig for imx_v7_var_defoonfig to use
   cp ${S}/arch/arm/configs/imx_v7_var_defconfig ${B}/.config
   cp ${S}/arch/arm/configs/imx_v7_var_defconfig ${B}/../defconfig
}


# Copy the config file required by ti-compat-wirless-wl18xx
do_deploy_append () {
   cp ${S}/arch/arm/configs/imx_v7_var_defconfig ${S}/.config
}


COMPATIBLE_MACHINE = "(var-som-mx6)"

DEFAULT_PREFERENCE = "1"

