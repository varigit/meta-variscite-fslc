LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS += "bison-native"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"

SRCBRANCH = "imx_v2020.04_5.4.70_2.3.0_var01"
SRCREV = "46d384f517a2dbe63c6161d2ecfd964fdc08bf89"
UBOOT_INITIAL_ENV_DEVICE = "sd"

SRCBRANCH_var-som-mx6 = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_var-som-mx6 = "e382ce1bbd5ce83e4f3b9dbeed5d04e41708aae5"
UBOOT_INITIAL_ENV_DEVICE_var-som-mx6 = "nand"

SRCBRANCH_imx6ul-var-dart = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx6ul-var-dart = "d93550dda0996abbc653e79851b3448bd5ed44a5"
UBOOT_INITIAL_ENV_DEVICE_imx6ul-var-dart = "nand"

SRCBRANCH_imx7-var-som = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx7-var-som = "59341359399c8caa4d27b9325b777b8062af80f9"
UBOOT_INITIAL_ENV_DEVICE_imx7-var-som = "nand"

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"
