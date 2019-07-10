FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
        file://wifi.sh \
"

FILES_${PN} += "/etc/pm/sleep.d/*"

do_install_append() {
	install -d ${D}/${sysconfdir}/pm/sleep.d
	install -m 0755 ${WORKDIR}/wifi.sh ${D}/${sysconfdir}/pm/sleep.d
}
