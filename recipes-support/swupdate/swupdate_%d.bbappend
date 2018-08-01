FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
	file://background.jpg \
	file://Variscite-Logo.png \
	file://swupdate.cfg \
	file://swupdate.default \
"

do_install_append () {
	install -m 755 ${WORKDIR}/background.jpg ${D}/www/images/
	install -m 755 ${WORKDIR}/Variscite-Logo.png ${D}/www/images/favicon.png
	install -m 755 ${WORKDIR}/Variscite-Logo.png ${D}/www/images/logo.png
	install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}/
	install -d ${D}${sysconfdir}/default/
	install -m 644 ${WORKDIR}/swupdate.default ${D}${sysconfdir}/default/swupdate
}
