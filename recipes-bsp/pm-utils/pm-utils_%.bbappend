FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	file://remove_default_sleep_d.diff \
        file://01-bt.sh \
        file://02-wifi.sh \
"

FILES_${PN} += "/etc/pm/sleep.d/*"

do_install_append() {
	install -d ${D}/${sysconfdir}/pm/sleep.d
	install -m 0755 ${WORKDIR}/01-bt.sh ${D}/${sysconfdir}/pm/sleep.d
	install -m 0755 ${WORKDIR}/02-wifi.sh ${D}/${sysconfdir}/pm/sleep.d
}
