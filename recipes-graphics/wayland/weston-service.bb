DESCRIPTION = "Startup service for a custom application"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES','systemd','','update-rc.d-native',d)}"

SRC_URI = " \
	file://weston-app.sh \
	file://weston-app.service \
"

do_install() {
	install -d ${D}${sysconfdir}/weston
	install -m 0755 ${WORKDIR}/weston-app.sh ${D}/${sysconfdir}/weston

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${systemd_unitdir}/system
		install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
		install -m 0644 ${WORKDIR}/weston-app.service ${D}/${systemd_unitdir}/system
 
		ln -sf ${systemd_unitdir}/system/weston-app.service \
			${D}${sysconfdir}/systemd/system/multi-user.target.wants/weston-app.service
	else
		install -d ${D}${sysconfdir}/init.d
		ln -s ${sysconfdir}/weston/weston-app.sh ${D}${sysconfdir}/init.d/weston-app.sh
		update-rc.d -r ${D} weston-app.sh start 5 S .
	fi
}

FILES_${PN} = " \ 
	${sysconfdir}/weston/*  \
	${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '${systemd_unitdir}/system/* ${sysconfdir}/systemd/system/multi-user.target.wants/*', \
			'${sysconfdir}/init.d ${sysconfdir}/rcS.d ${sysconfdir}/rc2.d ${sysconfdir}/rc3.d ${sysconfdir}/rc4.d ${sysconfdir}/rc5.d', d)} \
"
