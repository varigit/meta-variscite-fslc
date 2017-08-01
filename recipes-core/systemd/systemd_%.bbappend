FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " file://systemd-hostnamed.service"

do_install_append() {
	install -d ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/systemd-hostnamed.service ${D}${systemd_unitdir}/system 
}
