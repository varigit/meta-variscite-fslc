FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
        file://rc.local \
        file://rc.local.service \
"

FILES_${PN} += " \
	${systemd_unitdir}/system/* \
	${sysconfdir}/systemd/* \
"

do_install_append () {
    install -d ${D}/${sysconfdir}
    install -m 755 ${S}/rc.local ${D}/${sysconfdir}/rc.local

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
            install -d ${D}${systemd_unitdir}/system
	    install -d ${D}${sysconfdir}/systemd/system
            install -m 0644 ${WORKDIR}/rc.local.service ${D}${systemd_unitdir}/system

            ln -sf ${systemd_unitdir}/system/rc.local.service \
                            ${D}${sysconfdir}/systemd/system/rc.local.service
    fi	
}
