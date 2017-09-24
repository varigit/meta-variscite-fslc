FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

SRC_URI += " \
          file://init \
          file://pulseaudio-bluetooth.conf \
          file://system.pa \
"

DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES','systemd','','update-rc.d-native',d)}"

do_install_append() {
	install -d ${D}/${sysconfdir}/init.d
	install -d ${D}/${sysconfdir}/dbus-1/system.d
	install -d ${D}/${sysconfdir}/pulse

	install -m 0755 ${WORKDIR}/init ${D}/${sysconfdir}/init.d/pulseaudio
	install -m 0644 ${WORKDIR}/pulseaudio-bluetooth.conf ${D}/${sysconfdir}/dbus-1/system.d
	install -m 0644 ${WORKDIR}/system.pa ${D}/${sysconfdir}/pulse

	update-rc.d -r ${D} pulseaudio defaults
	rm -f ${D}/${sysconfdir}/xdg/autostart/pulseaudio.desktop
}
