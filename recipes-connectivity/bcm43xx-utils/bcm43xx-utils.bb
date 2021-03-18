DESCRIPTION = "Startup and config files for use with BCM43XX WIFI and Bluetooth"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES','systemd','','update-rc.d-native',d)}"

SRC_URI = " \
	file://variscite-wifi \
	file://variscite-wifi-common.sh \
	file://variscite-wifi.service \
	file://variscite-wifi.conf \
"

FILES_${PN} = " \ 
	${sysconfdir}/wifi/*  \
	${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '${systemd_unitdir}/system/* ${sysconfdir}/systemd/system/multi-user.target.wants/*', \
													   '${sysconfdir}/init.d ${sysconfdir}/rcS.d', d)} \
"

RDEPENDS_${PN}_imx8mq-var-dart = "i2c-tools"
RDEPENDS_${PN}_imx8mm-var-dart = "i2c-tools"
RDEPENDS_${PN}_imx8mn-var-som = "i2c-tools"
RDEPENDS_${PN}_append = " bash base-files"

S = "${WORKDIR}"

do_install() {
	install -d ${D}${sysconfdir}/wifi
	install -m 0644 ${WORKDIR}/variscite-wifi.conf ${D}${sysconfdir}/wifi
	install -m 0644 ${WORKDIR}/variscite-wifi-common.sh ${D}/${sysconfdir}/wifi
	install -m 0755 ${WORKDIR}/variscite-wifi ${D}/${sysconfdir}/wifi

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${systemd_unitdir}/system
		install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
		install -m 0644 ${WORKDIR}/variscite-wifi.service ${D}/${systemd_unitdir}/system
 
		ln -sf ${systemd_unitdir}/system/variscite-wifi.service \
			${D}${sysconfdir}/systemd/system/multi-user.target.wants/variscite-wifi.service
	else
		install -d ${D}${sysconfdir}/init.d
		ln -s ${sysconfdir}/wifi/variscite-wifi ${D}${sysconfdir}/init.d/variscite-wifi
		update-rc.d -r ${D} variscite-wifi start 5 S .
	fi
}

COMPATIBLE_MACHINE = "(imx6ul-var-dart|imx7-var-som|imx8mm-var-dart|imx8mn-var-som|imx8mq-var-dart|imx8qm-var-som|imx8qxp-var-som|imx8qxpb0-var-som)"
