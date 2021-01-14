# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2017 NXP
# Copyright 2018-2019 Variscite Ltd.
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Linux kernel provided and supported by Variscite"
DESCRIPTION = "Linux kernel provided and supported by Variscite (based on the kernel provided by NXP) \
with focus on i.MX Family SOMs. It includes support for many IPs such as GPU, VPU and IPU."

require recipes-kernel/linux/linux-imx.inc
include linux-common.inc

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

DEPENDS += "lzop-native bc-native"

# Do not copy the kernel image to the rootfs by default
RDEPENDS_${KERNEL_PACKAGE_NAME}-base = ""

DEFAULT_PREFERENCE = "1"

LOCALVERSION_var-som-mx6 = "-imx6ul"
LOCALVERSION_imx6ul-var-dart = "-imx6ul"
LOCALVERSION_imx8mq-var-dart = "-imx8mq"
LOCALVERSION_imx8mm-var-dart = "-imx8mm"
LOCALVERSION_imx8mn-var-som = "-imx8mn"
LOCALVERSION_imx8qxp-var-som = "-imx8x"
LOCALVERSION_imx8qm-var-som = "-imx8qm"

KBUILD_DEFCONFIG_var-som-mx6 = "imx_v7_var_defconfig"
KBUILD_DEFCONFIG_imx6ul-var-dart = "imx_v7_var_defconfig"
KBUILD_DEFCONFIG_imx7-var-som = "imx_v7_var_defconfig"
KBUILD_DEFCONFIG_imx8mq-var-dart = "imx8mq_var_dart_defconfig"
KBUILD_DEFCONFIG_imx8mm-var-dart = "imx8_var_defconfig"
KBUILD_DEFCONFIG_imx8mn-var-som = "imx8_var_defconfig"
KBUILD_DEFCONFIG_imx8qxp-var-som = "imx8_var_defconfig"
KBUILD_DEFCONFIG_imx8qm-var-som = "imx8_var_defconfig"

DEFAULT_DTB_imx8mq-var-dart = "sd-lvds"
DEFAULT_DTB_imx8qxp-var-som = "sd"
DEFAULT_DTB_imx8qm-var-som = "lvds"
DEFAULT_DTB_PREFIX_imx8mq-var-dart = "imx8mq-var-dart-dt8mcustomboard"
DEFAULT_DTB_PREFIX_imx8qxp-var-som = "imx8qxp-var-som-symphony"
DEFAULT_DTB_PREFIX_imx8qm-var-som = "imx8qm-var-som"

SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

pkg_postinst_kernel-devicetree_append () {
   rm -f $D/boot/devicetree-*
}

pkg_postinst_kernel-devicetree_append_imx8mq-var-dart () {
    cd $D/boot
    ln -s ${DEFAULT_DTB_PREFIX}-${DEFAULT_DTB}.dtb ${DEFAULT_DTB_PREFIX}.dtb
    ln -s ${DEFAULT_DTB_PREFIX}12-${DEFAULT_DTB}.dtb ${DEFAULT_DTB_PREFIX}12.dtb
}

pkg_postinst_kernel-devicetree_append_imx8qxp-var-som () {
    cd $D/boot
    ln -s ${DEFAULT_DTB_PREFIX}-${DEFAULT_DTB}.dtb ${DEFAULT_DTB_PREFIX}.dtb
}

pkg_postinst_kernel-devicetree_append_imx8qm-var-som () {
    cd $D/boot
    ln -s ${DEFAULT_DTB_PREFIX}-${DEFAULT_DTB}.dtb ${DEFAULT_DTB_PREFIX}.dtb
    ln -s imx8qm-var-spear-${DEFAULT_DTB}.dtb imx8qm-var-spear.dtb
}

# Added by meta-virtualization/recipes-kernel/linux/linux-yocto_5.4_virtualization.inc
KERNEL_FEATURES_remove = "cfg/virtio.scc"

COMPATIBLE_MACHINE = "(mx6|mx7|mx8)"
