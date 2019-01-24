# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2017 NXP
# Copyright 2018 Variscite Ltd.
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Linux Kernel provided and supported by NXP"
DESCRIPTION = "Linux Kernel provided and supported by NXP with focus on \
i.MX Family Reference Boards. It includes support for many IPs such as GPU, VPU and IPU."

require recipes-kernel/linux/linux-imx.inc
require recipes-kernel/linux/linux-dtb.inc

DEPENDS += "lzop-native bc-native"

DEFAULT_PREFERENCE = "1"

SRCBRANCH = "imx_4.9.51_imx8m_ga_var01"

LOCALVERSION = "-${SRCBRANCH}"
KERNEL_DEFCONFIG = "${S}/arch/arm64/configs/imx8m_var_dart_defconfig"
DEFAULT_DTB = "sd-emmc-dcss-lvds"

KERNEL_SRC ?= "git://github.com/varigit/linux-imx;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"
SRCREV = "891be4433e8fff947c5b08c1f0f024346d877481"

S = "${WORKDIR}/git"

addtask copy_defconfig after do_unpack before do_preconfigure
do_copy_defconfig () {
    cp ${KERNEL_DEFCONFIG} ${WORKDIR}/defconfig
}

pkg_postinst_kernel-devicetree_append () {
	cd $D/boot
	ln -s ${MACHINE}-${DEFAULT_DTB}.dtb ${MACHINE}.dtb
}

COMPATIBLE_MACHINE = "(imx8m-var-dart)"
EXTRA_OEMAKE_append_mx8 = " ARCH=arm64"
