FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imx8m-var-dart = " \
        file://imx8m-wifi.sh \
"

SRC_URI_append_imx8mm-var-dart = " \
        file://imx8mm-wifi.sh \
"

FILES_${PN} += "/etc/pm/sleep.d/*"

do_install_append_imx8m-var-dart() {
	install -d ${D}/${sysconfdir}/pm/sleep.d
	install -m 0755 ${WORKDIR}/imx8m-wifi.sh ${D}/${sysconfdir}/pm/sleep.d
}

do_install_append_imx8mm-var-dart() {
	install -d ${D}/${sysconfdir}/pm/sleep.d
	install -m 0755 ${WORKDIR}/imx8mm-wifi.sh ${D}/${sysconfdir}/pm/sleep.d
}
