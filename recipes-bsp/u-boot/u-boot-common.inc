LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"
SRCBRANCH = "imx_v2018.03_4.14.78_1.0.0_ga_var01"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRCREV = "1d54774f903165d79b2f9ab003e9b5e37c66bd5f"

S = "${WORKDIR}/git"

