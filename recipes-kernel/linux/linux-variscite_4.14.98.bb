# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2017 NXP
# Copyright 2018-2019 Variscite Ltd.
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Linux kernel provided and supported by Variscite"
DESCRIPTION = "Linux kernel provided and supported by Variscite (based on the kernel provided by NXP) \
with focus on i.MX Family SOMs. It includes support for many IPs such as GPU, VPU and IPU."

require recipes-kernel/linux/linux-imx.inc

DEPENDS += "lzop-native bc-native"

DEFAULT_PREFERENCE = "1"

SRCBRANCH = "imx_4.14.98_2.0.0_ga_var01"

LOCALVERSION_imx8m-var-dart = "-imx8m"
LOCALVERSION_imx8mm-var-dart = "-imx8mm"
LOCALVERSION_imx8qxp-var-som = "-imx8x"
LOCALVERSION_imx8qm-var-som = "-imx8qm"

KERNEL_DEFCONFIG = "${S}/arch/arm64/configs/imx8_var_defconfig"
DEFAULT_DTB_imx8m-var-dart = "sd-emmc-lvds"
DEFAULT_DTB_imx8qxp-var-som = "sd"
DEFAULT_DTB_PREFIX_imx8m-var-dart = "fsl-imx8mq-var-dart"
DEFAULT_DTB_PREFIX_imx8qxp-var-som = "fsl-imx8qxp-var-som"

KERNEL_SRC ?= "git://github.com/varigit/linux-imx;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"
SRCREV = "c5aac7f2415f1351e10f70cdb8449228713affd5"

S = "${WORKDIR}/git"

addtask copy_defconfig after do_patch before do_preconfigure
do_copy_defconfig () {
    cp ${KERNEL_DEFCONFIG} ${WORKDIR}/defconfig
}

pkg_postinst_kernel-devicetree_append () {
   rm -f $D/boot/devicetree-*
}

pkg_postinst_kernel-devicetree_append_imx8m-var-dart () {
    cd $D/boot
    ln -s ${DEFAULT_DTB_PREFIX}-${DEFAULT_DTB}.dtb ${DEFAULT_DTB_PREFIX}.dtb
    ln -s ${DEFAULT_DTB_PREFIX}-${DEFAULT_DTB}-cb12.dtb ${DEFAULT_DTB_PREFIX}-cb12.dtb
}

pkg_postinst_kernel-devicetree_append_imx8qxp-var-som () {
    cd $D/boot
    ln -s ${DEFAULT_DTB_PREFIX}-${DEFAULT_DTB}.dtb ${DEFAULT_DTB_PREFIX}.dtb
}

COMPATIBLE_MACHINE = "(imx8m-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qm-var-som)"
EXTRA_OEMAKE_append_mx8 = " ARCH=arm64"
