SUMMARY = "U-Boot bootloader fw_printenv/setenv utilities"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/gpl-2.0.txt;md5=b234ee4d69f5fce4486a80fdaf4a4263"
SECTION = "bootloader"
DEPENDS = "mtd-utils"

SRCBRANCH_var-som-mx6 = "imx_v2015.04_4.1.15_1.1.0_ga_var02"
SRCBRANCH_imx6ul-var-dart = "imx_v2015.10_dart_6ul_var1"
SRCBRANCH_imx7-var-som = "imx_v2015.04_4.1.15_1.1.0_ga_var02"
UBOOT_SRC = "git://github.com/varigit/uboot-imx.git;protocol=git"
SRC_URI = "${UBOOT_SRC};branch=${SRCBRANCH}"
SRC_URI += "file://default-gcc.patch \
            file://0001-Revert-Fix-the-compile-issue-under-gcc6.patch \
            file://0001-compiler-.h-sync-include-linux-compiler-.h-with-Linu.patch \
           "

SRCREV_var-som-mx6 = "e09e375e0d5fa0e4f232a1fbffe5b9e20a93e687"
SRCREV_imx7-var-som = "e09e375e0d5fa0e4f232a1fbffe5b9e20a93e687"
SRCREV_imx6ul-var-dart = "404c3c0618cd484fb319b8a8bc4cba8573b103e1"

S = "${WORKDIR}/git"

INSANE_SKIP_${PN} = "already-stripped"
EXTRA_OEMAKE_class-target = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${CC} ${CFLAGS} ${LDFLAGS}" HOSTCC="${BUILD_CC} ${BUILD_CFLAGS} ${BUILD_LDFLAGS}" V=1'
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
