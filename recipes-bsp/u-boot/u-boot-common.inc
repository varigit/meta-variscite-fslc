LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS += "bison-native"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"

SRCBRANCH = "imx_v2020.04_5.4.24_2.1.0_var01"
SRCREV = "455f3570fb9192a6d893ee33f7be408bf4f8b07b"

SRCBRANCH_imx6ul-var-dart = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx6ul-var-dart = "717f29898abe82ffa2d74515806c46094075285a"
UBOOT_INITIAL_ENV_imx6ul-var-dart = ""

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"
