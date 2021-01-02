LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS += "bison-native"

UBOOT_SRC ?= "git://github.com/varigit/uboot-imx;protocol=git"

SRCBRANCH = "imx_v2020.04_5.4.24_2.1.0_var02"
SRCREV = "777a7e331587a9a978e15b6b5f66f77e44c483a5"

SRCBRANCH_var-som-mx6 = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_var-som-mx6 = "eed279256bc24cffeb97e91b594d56591a457380"
UBOOT_INITIAL_ENV_var-som-mx6 = ""

SRCBRANCH_imx6ul-var-dart = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx6ul-var-dart = "00a86ee32e2c7957fe7b57c83a165f0ec19d52bb"
UBOOT_INITIAL_ENV_imx6ul-var-dart = ""

SRCBRANCH_imx7-var-som = "imx_v2018.03_4.14.78_1.0.0_ga_var02"
SRCREV_imx7-var-som = "00a86ee32e2c7957fe7b57c83a165f0ec19d52bb"
UBOOT_INITIAL_ENV_imx7-var-som = ""

SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"

S = "${WORKDIR}/git"
