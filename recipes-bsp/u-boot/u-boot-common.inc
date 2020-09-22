LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS += "bison-native"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"

SRCBRANCH = "lf-5.4.y_v2019.04_var01"
SRCREV = "74c22e7054d00f8fd8ac8b00ab89e5c0e0a50f7f"

SRCBRANCH_imx6ul-var-dart = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx6ul-var-dart = "717f29898abe82ffa2d74515806c46094075285a"

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"
