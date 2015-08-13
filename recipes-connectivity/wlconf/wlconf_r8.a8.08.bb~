DESCRIPTION = "Configuration utility for TI wireless drivers"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=21;md5=adc05a1903d3f107f85c90328e3a9438"

PV = "R8.5+git${SRCPV}"

PR = "r3"

# Tag: R8.5
SRCREV = "dcf0800f30ba449cd7f3a20f8b3f4853dc829652"
SRC_URI = "git://git.ti.com/wilink8-wlan/18xx-ti-utils.git"

S = "${WORKDIR}/git/wlconf"

EXTRA_OEMAKE = "CC=${TARGET_PREFIX}gcc"

do_install() {
	install -d ${D}${bindir}
	install -d ${D}${bindir}/wlconf/
	install -d ${D}${bindir}/wlconf/official_inis
	install -d ${D}/lib/firmware/ti-connectivity

	install -m 0755 wlconf ${D}${bindir}/wlconf/
	install -m 0755 dictionary.txt ${D}${bindir}/wlconf/
	install -m 0755 struct.bin ${D}${bindir}/wlconf/
	install -m 0755 default.conf ${D}${bindir}/wlconf/
	install -m 0755 wl18xx-conf-default.bin ${D}${bindir}/wlconf/
	install -m 0755 wl18xx-conf-default.bin ${D}/lib/firmware/ti-connectivity/wl18xx-conf.bin
	install -m 0755 README ${D}${bindir}/wlconf/
	install -m 0755 example.conf ${D}${bindir}/wlconf/
	install -m 0755 example.ini ${D}${bindir}/wlconf/
	install -m 0755 configure-device.sh ${D}${bindir}/wlconf/
	install -m 0755 ${S}/official_inis/* \
			${D}${bindir}/wlconf/official_inis/
}

FILES_${PN} += " \
	${bindir}/wlconf \
	${bindir}/wlconf/official_inis \
	/lib/firmware/ti-connectivity/wl18xx-conf.bin \
"

FILES_${PN}-dbg += "${bindir}/wlconf/.debug"
