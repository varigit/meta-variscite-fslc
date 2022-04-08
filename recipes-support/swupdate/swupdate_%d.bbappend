FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


SRC_URI = "git://github.com/sbabic/swupdate.git;protocol=http \
	file://defconfig \
	file://swupdate \
	file://swupdate.service \
	file://head_bg.gif \
	file://swupdate.cfg \
	file://swupdate.default \
	file://suid.patch \
"

do_install_append () {
	install -m 755 ${WORKDIR}/head_bg.gif ${D}/www/
	install -m 644 ${WORKDIR}/swupdate.cfg ${D}${sysconfdir}/
	install -d ${D}${sysconfdir}/default/
	install -m 644 ${WORKDIR}/swupdate.default ${D}${sysconfdir}/default/swupdate
}
