FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
	file://main.conf \
	file://audio.conf \
	file://bluetooth \
	file://obexd \
	file://obexd.conf \
	file://obex.service \
	file://bluetooth.service \
"

# Required by obexd
RDEPENDS_${PN}_append_libc-glibc = " glibc-gconv-utf-16"

DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES','systemd','','update-rc.d-native',d)}"

do_install_append() {
	install -d ${D}${sysconfdir}/bluetooth
	install -d ${D}${sysconfdir}/dbus-1/system.d
	install -d ${D}${sysconfdir}/profile.d
	install -m 0644 ${WORKDIR}/audio.conf ${D}/${sysconfdir}/bluetooth
	install -m 0644 ${WORKDIR}/main.conf ${D}/${sysconfdir}/bluetooth
	install -m 0644 ${WORKDIR}/obexd.conf ${D}${sysconfdir}/dbus-1/system.d

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${systemd_unitdir}/system
		install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
		install -m 0644 ${WORKDIR}/obex.service ${D}${systemd_unitdir}/system
		install -m 0644 ${WORKDIR}/bluetooth.service ${D}${systemd_unitdir}/system

		ln -sf ${systemd_unitdir}/system/obex.service \
			${D}${sysconfdir}/systemd/system/multi-user.target.wants/obex.service

	else
		install -m 0755 ${WORKDIR}/obexd ${D}${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/bluetooth ${D}${sysconfdir}/init.d
		update-rc.d -r ${D} bluetooth defaults
		update-rc.d -r ${D} obexd defaults
	fi
}
