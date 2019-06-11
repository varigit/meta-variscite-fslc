LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"
SRCBRANCH = "imx_v2018.03_4.14.98_2.0.0_ga_var01"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRCREV = "4d883f0ecf626780ba4eced0e6af8eddfa6dcc3b"

S = "${WORKDIR}/git"

