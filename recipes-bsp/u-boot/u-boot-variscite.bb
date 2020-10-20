# Copyright (C) 2013-2016 Freescale Semiconductor
# Copyright 2017-2018 NXP
# Copyright 2018-2019 Variscite Ltd.

SUMMARY = "U-Boot for Variscite's i.MX boards"
require recipes-bsp/u-boot/u-boot.inc

PROVIDES += "u-boot"
DEPENDS += "bison-native bc-native dtc-native"

include u-boot-common.inc

inherit fsl-u-boot-localversion

LOCALVERSION ?= "-${SRCBRANCH}"

BOOT_TOOLS = "imx-boot-tools"

do_deploy_append_mx8m () {
    # Deploy the mkimage, u-boot-nodtb.bin and the U-Boot dtb for mkimage to generate boot binary
    if [ -n "${UBOOT_CONFIG}" ]
    then
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1);
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1);
                if [ $j -eq $i ]
                then
                    install -d ${DEPLOYDIR}/${BOOT_TOOLS}
                    install -m 0777 ${B}/${config}/arch/arm/dts/${UBOOT_DTB_NAME}  ${DEPLOYDIR}/${BOOT_TOOLS}
                    for dtb in ${UBOOT_DTB_EXTRA}; do
                        install -m 0777 ${B}/${config}/arch/arm/dts/${dtb} ${DEPLOYDIR}/${BOOT_TOOLS}
                    done
                    install -m 0777 ${B}/${config}/u-boot-nodtb.bin  ${DEPLOYDIR}/${BOOT_TOOLS}/u-boot-nodtb.bin-${MACHINE}-${UBOOT_CONFIG}
                fi
            done
            unset  j
        done
        unset  i
    fi

}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(imx6ul-var-dart|imx8mq-var-dart|imx8mm-var-dart|imx8mn-var-som|imx8qxp-var-som|imx8qm-var-som)"

UBOOT_NAME_mx6 = "u-boot-${MACHINE}.bin-${UBOOT_CONFIG}"
UBOOT_NAME_mx7 = "u-boot-${MACHINE}.bin-${UBOOT_CONFIG}"
UBOOT_NAME_mx8 = "u-boot-${MACHINE}.bin-${UBOOT_CONFIG}"
