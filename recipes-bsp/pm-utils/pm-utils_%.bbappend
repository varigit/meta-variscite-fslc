FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
        file://remove_default_sleep_d.diff \
"

SRC_URI_append_imx6ul-var-dart = " \
        file://imx6ul-wifi.sh \
"

SRC_URI_append_imx7-var-som = " \
        file://imx7-wifi.sh \
"

FILES_${PN} += "/etc/pm/sleep.d/*"

do_install_append_imx6ul-var-dart() {
	install -d ${D}/${sysconfdir}/pm/sleep.d
	install -m 0755 ${WORKDIR}/imx6ul-wifi.sh ${D}/${sysconfdir}/pm/sleep.d
}

do_install_append_imx7-var-som() {
	install -d ${D}/${sysconfdir}/pm/sleep.d
	install -m 0755 ${WORKDIR}/imx7-wifi.sh ${D}/${sysconfdir}/pm/sleep.d
}
