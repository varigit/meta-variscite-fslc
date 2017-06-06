SUMMARY = "U-Boot bootloader fw_printenv/setenv utilities"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"
SECTION = "bootloader"
DEPENDS = "mtd-utils"

SRCBRANCH = "imx_v2015.04_4.1.15_1.1.0_ga_var03"
UBOOT_SRC = "git://github.com/varigit/uboot-imx.git;protocol=git"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRCREV = "0351feb6765d1f060a0c62253bc51421b90b0e3c"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

S = "${WORKDIR}/git"

INSANE_SKIP_${PN} = "already-stripped"
EXTRA_OEMAKE_class-target = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${CC} ${CFLAGS} ${LDFLAGS}" V=1'
EXTRA_OEMAKE_class-cross = 'ARCH=${TARGET_ARCH} CC="${CC} ${CFLAGS} ${LDFLAGS}" V=1'

inherit uboot-config

do_compile_var-som-mx6 () {
	oe_runmake mx6var_som_nand_defconfig
	oe_runmake env
}

do_compile_imx6ul-var-dart () {
	oe_runmake mx6ul_var_dart_nand_defconfig
	oe_runmake env
}

do_compile_imx7-var-som () {
	oe_runmake mx7dvar_som_nand_defconfig
	oe_runmake env
}

do_install () {
	install -d ${D}${base_sbindir}
	install -d ${D}${sysconfdir}
	install -m 755 ${S}/tools/env/fw_printenv ${D}${base_sbindir}/fw_printenv
	ln -s ${base_sbindir}/fw_printenv ${D}${base_sbindir}/fw_setenv
	install -m 0644 ${THISDIR}/${PN}/${MACHINE}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

do_install_class-cross () {
	install -d ${D}${bindir_cross}
	install -m 755 ${S}/tools/env/fw_printenv ${D}${bindir_cross}/fw_printenv
	ln -s ${base_sbindir}/fw_printenv ${D}${bindir_cross}/fw_setenv
}

SYSROOT_PREPROCESS_FUNCS_class-cross = "uboot_fw_utils_cross"
uboot_fw_utils_cross() {
	sysroot_stage_dir ${D}${bindir_cross} ${SYSROOT_DESTDIR}${bindir_cross}
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
BBCLASSEXTEND = "cross"
