SUMMARY = "U-Boot for Variscite's i.MX boards"
require recipes-bsp/u-boot/u-boot.inc
require u-boot-common.inc

inherit fsl-u-boot-localversion

LOCALVERSION_var-som-mx6 = "-mx6"
LOCALVERSION_imx6ul-var-dart = "-mx6ul"
LOCALVERSION_imx7-var-som = "-mx7"

PROVIDES += "u-boot"

# avoid autodetecting swig: in yocto < 2.3 it creates problems
do_compile_prepend_imx7-var-som () {
	sed 's@which swig@false@g' -i ${S}/tools/Makefile
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
COMPATIBLE_MACHINE = "(var-som-mx6|imx6ul-var-dart|imx7-var-som)"
