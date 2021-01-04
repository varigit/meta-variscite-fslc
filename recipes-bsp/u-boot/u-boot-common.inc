LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS += "bison-native"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"

SRCBRANCH = "imx_v2020.04_5.4.24_2.1.0_var02"
SRCREV = "41c106057db0c19a4efd0319a46b0af102d65dc8"
UBOOT_INITIAL_ENV_DEVICE = "sd"

SRCBRANCH_var-som-mx6 = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_var-som-mx6 = "d25c71736ec9f62266df728e60a771d69958db23"
UBOOT_INITIAL_ENV_DEVICE_var-som-mx6 = "nand"

SRCBRANCH_imx6ul-var-dart = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx6ul-var-dart = "d25c71736ec9f62266df728e60a771d69958db23"
UBOOT_INITIAL_ENV_DEVICE_imx6ul-var-dart = "nand"

SRCBRANCH_imx7-var-som = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx7-var-som = "d25c71736ec9f62266df728e60a771d69958db23"
UBOOT_INITIAL_ENV_DEVICE_imx7-var-som = "nand"

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"
