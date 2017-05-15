SUMMARY = "U-Boot for Variscite's i.MX boards"
require u-boot-common.inc
require recipes-bsp/u-boot/u-boot.inc

inherit fsl-u-boot-localversion

LOCALVERSION_var-som-mx6 = "-mx6"
LOCALVERSION_imx6ul-var-dart = "-mx6ul"
LOCALVERSION_imx7-var-som = "-mx7"

PROVIDES += "u-boot"

SRC_URI += "file://0001-compiler-.h-sync-include-linux-compiler-.h-with-Linu.patch"

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(var-som-mx6|imx6ul-var-dart|imx7-var-som)"
