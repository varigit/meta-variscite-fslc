DESCRIPTION = "The calibrator utility for TI wireless solution based on wl18xx driver"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING;md5=4725015cb0be7be389cf06deeae3683d"

DEPENDS = "libnl"
RDEPENDS_${PN} = "wl18xx-fw"

#Tag: R8.7_SP3 (8.7.3)
SRCREV = "5048b59a444ac59ba7171d6e122d5a84581aebf2"
SRC_URI = "git://git.ti.com/wilink8-wlan/18xx-ti-utils.git \
           file://0001-plt.h-Do-not-define-EFUSE_PARAMETER_TYPE_ENMT-type-e.patch \  
          "

S = "${WORKDIR}/git"

export CROSS_COMPILE = "${TARGET_PREFIX}"

EXTRA_OEMAKE = "CFLAGS="${CFLAGS} -I${STAGING_INCDIR}/libnl3/ -DCONFIG_LIBNL32 " \
		LDFLAGS="${LDFLAGS} -L${STAGING_LIBDIR}" \
		CC="${CC}" \
		NLVER=3"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 calibrator ${D}${bindir}/
}
