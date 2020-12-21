SUMMARY = "U-Boot bootloader fw_printenv/setenv utilities"
include u-boot-common.inc

DEPENDS += "mtd-utils"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://fw_env.config"

INSANE_SKIP_${PN} = "already-stripped"
EXTRA_OEMAKE_class-target = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${CC} ${CFLAGS} ${LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" V=1'
EXTRA_OEMAKE_class-cross = 'ARCH=${TARGET_ARCH} CC="${CC} ${CFLAGS} ${LDFLAGS}" V=1'

inherit uboot-config

do_compile_var-som-mx6 () {
	oe_runmake mx6var_som_sd_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx6var_som_nand_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-nand
	ln -s fw_printenv-nand tools/env/fw_printenv
}

do_compile_imx6ul-var-dart () {
	oe_runmake mx6ul_var_dart_mmc_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx6ul_var_dart_nand_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-nand
	ln -s fw_printenv-nand tools/env/fw_printenv
}

do_compile_imx7-var-som () {
	oe_runmake mx7dvar_som_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-mmc
	oe_runmake mx7dvar_som_nand_defconfig
	oe_runmake envtools
	mv tools/env/fw_printenv tools/env/fw_printenv-nand
	ln -s fw_printenv-nand tools/env/fw_printenv
}

do_compile_imx8mq-var-dart () {
	oe_runmake imx8mq_var_dart_defconfig
	oe_runmake envtools
}

do_compile_imx8mm-var-dart () {
	oe_runmake imx8mm_var_dart_defconfig
	oe_runmake envtools
}

do_compile_imx8mn-var-som () {
        oe_runmake imx8mn_var_som_defconfig
        oe_runmake envtools
}

do_compile_imx8qxp-var-som () {
	oe_runmake imx8qxp_var_som_defconfig
	oe_runmake envtools
}

do_compile_imx8qm-var-som () {
	oe_runmake imx8qm_var_som_defconfig
	oe_runmake envtools
}

do_install () {
	install -d ${D}${base_sbindir}
	install -d ${D}${sysconfdir}
	install -m 755 ${S}/tools/env/fw_printenv* ${D}${base_sbindir}/
	ln -s ${base_sbindir}/fw_printenv ${D}${base_sbindir}/fw_setenv
	install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config

	# With latest swupdate, libubootenv is provided by libubootenv.bb
	# For now, use libubootenv provided by legacy u-boot-fw-utils instead
	install -d ${D}${libdir}
	install -m 644  ${S}/tools/env/lib.a ${D}${libdir}/libubootenv.a
}

do_install_class-cross () {
	install -d ${D}${bindir_cross}
	install -m 755 ${S}/tools/env/fw_printenv ${D}${bindir_cross}/fw_printenv
	ln -s ${bindir_cross}/fw_printenv ${D}${bindir_cross}/fw_setenv
}

SYSROOT_DIRS_append_class-cross = " ${bindir_cross}"

PACKAGE_ARCH = "${MACHINE_ARCH}"
BBCLASSEXTEND = "cross"
