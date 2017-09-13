FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
	file://init \
	file://defaults \
"

do_install_append() {
	install -d ${D}/${sysconfdir}/init.d
	install -d ${D}/${sysconfdir}/default
	install -m 0755 ${WORKDIR}/init ${D}/${sysconfdir}/init.d/hostapd
	install -m 0644 ${WORKDIR}/defaults ${D}/${sysconfdir}/default/hostapd
}
