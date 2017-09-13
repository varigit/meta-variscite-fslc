DESCRIPTION = "Laird compat-wireless drivers for brcmfmac"
SECTION = "kernel/modules"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

RDEPENDS_${PN} = "wireless-tools"

PV = "3.5.5.8"
inherit module

SRCREV = "e82ec335896e1becca0ce9d0d2a4dedc9106216b"
BRANCH = "3.5.5.8"

SRC_URI = "git://github.com/varigit/laird-linux-backports.git;protocol=git;branch=${BRANCH}"

export KLIB_BUILD="${STAGING_KERNEL_BUILDDIR}"
export KLIB="${D}"

do_configure() {
    cd ${WORKDIR}/git
    CC=gcc make defconfig-lwb-fcc-var
}

do_compile() {
    cd ${WORKDIR}/git
    oe_runmake
}

do_install() {
    cd ${WORKDIR}/git
    oe_runmake INSTALL_MOD_PATH="${D}" modules_install
}
