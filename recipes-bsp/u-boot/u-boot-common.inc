LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"
SRCBRANCH = "imx_v2018.03_4.14.98_2.0.0_ga_var01"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRCREV = "ab8487bcfb1551e4384e4afc9c909c0cfa69313f"

S = "${WORKDIR}/git"

