SUMMARY = "U-Boot bootloader fw_printenv/setenv utilities"
require u-boot-common.inc
DEPENDS += "mtd-utils"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://fw_env.config"

INSANE_SKIP_${PN} = "already-stripped"
EXTRA_OEMAKE_class-target = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${CC} ${CFLAGS} ${LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" V=1'
EXTRA_OEMAKE_class-cross = 'HOSTCC="${CC} ${CFLAGS} ${LDFLAGS}" V=1'

inherit uboot-config

do_compile_var-som-mx6 () {
	oe_runmake mx6var_som_sd_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx6var_som_nand_defconfig
	oe_runmake envtools
}

do_compile_imx6ul-var-dart () {
	oe_runmake mx6ul_var_dart_mmc_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx6ul_var_dart_nand_defconfig
	oe_runmake envtools
}

do_compile_imx7-var-som () {
	oe_runmake mx7dvar_som_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx7dvar_som_nand_defconfig
	oe_runmake envtools
}

do_install () {
	install -d ${D}${base_sbindir}
	install -d ${D}${sysconfdir}
	install -m 755 ${S}/tools/env/fw_printenv-mmc ${D}${base_sbindir}/fw_printenv-mmc
	install -m 755 ${S}/tools/env/fw_printenv ${D}${base_sbindir}/fw_printenv-nand
	ln -s ${base_sbindir}/fw_printenv-nand ${D}${base_sbindir}/fw_printenv
	ln -s ${base_sbindir}/fw_printenv ${D}${base_sbindir}/fw_setenv
	install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

do_install_class-cross () {
	install -d ${D}${bindir_cross}
	install -m 755 ${S}/tools/env/fw_printenv ${D}${bindir_cross}/fw_printenv
	ln -s ${bindir_cross}/fw_printenv ${D}${bindir_cross}/fw_setenv
}

SYSROOT_DIRS_append_class-cross = " ${bindir_cross}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
BBCLASSEXTEND = "cross"
