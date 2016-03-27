require recipes-bsp/u-boot/u-boot1.inc

DESCRIPTION = "u-boot for Variscite SOM platforms"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PROVIDES = "u-boot"


SRCREV = "dfd1b8b73e406e3b7d5b51aca0d0f6e392e6107c"
SRCBRANCH = "imx_v2013.10_var4"
SRC_URI = "git://github.com/varigit/uboot-imx.git;protocol=git;branch=${SRCBRANCH}"
LIC_FILES_CHKSUM = "file://README;md5=56bd0740d61aff7b51a1ddff19bf1b05"

S = "${WORKDIR}/git"

PACKAGE_ARCH = "${MACHINE_ARCH}"

COMPATIBLE_MACHINE = "(var-som-mx6)"

