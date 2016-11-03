# Append path for freescale layer to include alsa-state asound.conf
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


SRC_URI_append = " \
        file://asound.state \
"

do_install_append() {
    install -m 0644 ${WORKDIR}/asound.state ${D}${localstatedir}/lib/alsa/asound.state
}

