SECTION = "bootloaders"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRCBRANCH = "imx_v2018.03_4.14.78_1.0.0_ga_var01"
UBOOT_SRC = "git://github.com/varigit/uboot-imx.git;protocol=git"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRCREV = "b7afa134a1a02e79342bfcd4947b702e18138c83"

S = "${WORKDIR}/git"
