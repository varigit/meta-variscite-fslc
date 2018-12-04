SECTION = "bootloaders"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRCBRANCH = "imx_v2017.03_4.9.11_1.0.0_ga_var01"
UBOOT_SRC = "git://github.com/varigit/uboot-imx.git;protocol=git"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH} \
           file://0001-tools-allow-to-override-python.patch \
           "
SRCREV = "e68eee26d6e0877fedbf670c362d5c94d961dede"

S = "${WORKDIR}/git"
