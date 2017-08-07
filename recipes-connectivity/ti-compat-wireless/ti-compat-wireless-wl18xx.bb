# This is a TI specific version of the compat-wireless recipe using a
# compat-wireless package created from the TI Systems Tested mac80211 releases.

DESCRIPTION = "ti compat-wireless drivers for wl18xx"
HOMEPAGE = "https://git.ti.com/wilink8-wlan/wl18xx"
SECTION = "kernel/modules"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://../backports/COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

RDEPENDS_${PN} = "wireless-tools"

PV = "R8.7_SP2"
inherit module

# Tags: R8.7_SP2
SRCREV_wl18xx = "5c94cc59baf694fb0aa5c5af6c6ae2a9b2d0e8fb"
BRANCH_wl18xx = "upstream_44"
SRCREV_backports = "d4777ef8ac84a855b7e385b01a6690874460f536"
BRANCH_backports = "upstream_44"

SRCREV_FORMAT = "wl18xx"

S = "${WORKDIR}/compat-wireless"

SRC_URI = "git://git.ti.com/wilink8-wlan/wl18xx.git;branch=${BRANCH_wl18xx};destsuffix=wl18xx;name=wl18xx \
           git://git.ti.com/wilink8-wlan/backports.git;branch=${BRANCH_backports};destsuffix=backports;name=backports \
"

export KLIB_BUILD="${STAGING_KERNEL_BUILDDIR}"
export KLIB="${D}"

do_configure() {
    cd "${WORKDIR}/backports"
    unset CC
    #Generate compat-wireless
    python ./gentree.py --clean  "${WORKDIR}/wl18xx" "${WORKDIR}/compat-wireless"

    cd ${S}

    make defconfig-wl18xx
}

do_install() {
    # Install modules
    oe_runmake modules_install
}
