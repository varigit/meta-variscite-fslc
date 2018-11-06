LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"
SRCBRANCH = "imx_v2017.03_4.9.51_imx8m_ga_var01"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRCREV = "94b89097f42ef0f352b135166c83213d1a3b3a1b"

S = "${WORKDIR}/git"

