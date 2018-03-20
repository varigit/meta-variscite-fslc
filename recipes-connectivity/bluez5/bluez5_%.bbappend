NOINST_TOOLS_READLINE_append = " \
    tools/btmgmt \
"

NOINST_TOOLS_EXPERIMENTAL_remove = " \
    tools/btmgmt \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
	file://variscite-bt \
	file://variscite-bt.service \
	file://variscite-bt.conf \
	file://main.conf \
	file://audio.conf \
	file://bluetooth \
	file://obexd \
	file://obexd.conf \
	file://obex.service \
"

# Required by obexd
RDEPENDS_${PN} += "glibc-gconv-utf-16"

do_install_append() {
	install -d ${D}${sysconfdir}/bluetooth
	install -d ${D}${sysconfdir}/dbus-1/system.d
	install -d ${D}${sysconfdir}/profile.d
	install -m 0644 ${WORKDIR}/variscite-bt.conf ${D}${sysconfdir}/bluetooth
	install -m 0755 ${WORKDIR}/variscite-bt ${D}${sysconfdir}/bluetooth
	install -m 0644 ${WORKDIR}/audio.conf ${D}/${sysconfdir}/bluetooth
	install -m 0644 ${WORKDIR}/main.conf ${D}/${sysconfdir}/bluetooth
	install -m 0644 ${WORKDIR}/obexd.conf ${D}${sysconfdir}/dbus-1/system.d

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${systemd_unitdir}/system
		install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
		install -m 0644 ${WORKDIR}/variscite-bt.service ${D}${systemd_unitdir}/system
		install -m 0644 ${WORKDIR}/obex.service ${D}${systemd_unitdir}/system

		ln -sf ${systemd_unitdir}/system/variscite-bt.service \
			${D}${sysconfdir}/systemd/system/multi-user.target.wants/variscite-bt.service

		ln -sf ${systemd_unitdir}/system/obex.service \
			${D}${sysconfdir}/systemd/system/multi-user.target.wants/obex.service

	else
		install -m 0755 ${WORKDIR}/obexd ${D}${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/bluetooth ${D}${sysconfdir}/init.d

		ln -s ${sysconfdir}/bluetooth/variscite-bt ${D}${sysconfdir}/init.d/variscite-bt

		update-rc.d -r ${D} variscite-bt start 99 2 3 4 5 .
		update-rc.d -r ${D} bluetooth defaults
		update-rc.d -r ${D} obexd defaults
	fi
}

SRC_URI_append_imx6ul-var-dart = " \
	file://variscite-bt-lwb5.conf \
"

do_install_append_imx6ul-var-dart() {
	install -m 0644 ${WORKDIR}/variscite-bt-lwb5.conf ${D}${sysconfdir}/bluetooth
}
