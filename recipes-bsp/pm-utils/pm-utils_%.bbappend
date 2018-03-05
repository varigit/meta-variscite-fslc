FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imx6ul-var-dart = " \
        file://imx6ul-wifi.sh \
        file://blacklist.conf \
"

FILES_${PN} += "/etc/pm/sleep.d/*"
FILES_${PN} += "/etc/pm/config.d/*"

do_install_append_imx6ul-var-dart() {
	install -d ${D}/${sysconfdir}/pm/sleep.d
	install -d ${D}/${sysconfdir}/pm/config.d
	install -m 0755 ${WORKDIR}/imx6ul-wifi.sh ${D}/${sysconfdir}/pm/sleep.d
	install -m 0644 ${WORKDIR}/blacklist.conf ${D}/${sysconfdir}/pm/config.d
}
