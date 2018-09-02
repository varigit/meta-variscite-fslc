SECTION = "bootloaders"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRCBRANCH = "imx_v2015.04_4.1.15_1.1.0_ga_var03"
SRCBRANCH_imx7-var-som = "imx_v2017.03_4.9.11_1.0.0_ga_var01"
UBOOT_SRC = "git://github.com/varigit/uboot-imx.git;protocol=git"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRCREV = "2087693dd84ac05ebdfd4cf505e63d304a26ade4"
SRCREV_imx7-var-som = "466898df5360675516bf1f014e5d48e507ae5c95"

S = "${WORKDIR}/git"
