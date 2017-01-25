FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_var-som-mx6 = " \
	file://variscite-touch \
	file://variscite-touch.service \
"

FILES_${PN} += "${systemd_unitdir}/system/*"

do_install_append_var-som-mx6() {

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${sysconfdir}/X11
		install -d ${D}${systemd_unitdir}/system
		install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants

		install -m 0644 ${WORKDIR}/variscite-touch.service ${D}${systemd_unitdir}/system
		install -m 0755 ${WORKDIR}/variscite-touch ${D}${sysconfdir}/X11

		ln -sf ${systemd_unitdir}/system/variscite-touch.service \
				${D}${sysconfdir}/systemd/system/multi-user.target.wants/variscite-touch.service
	else
		install -d ${D}${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/variscite-touch ${D}${sysconfdir}/init.d
		update-rc.d -r ${D} variscite-touch start 99 2 3 4 5 .
	fi
}
