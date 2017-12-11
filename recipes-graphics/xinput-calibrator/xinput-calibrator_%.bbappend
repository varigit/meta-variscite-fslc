do_install_append() {
    rm -rf ${D}${sysconfdir}/xdg/autostart/
}

FILES_${PN}_remove = "${sysconfdir}/xdg/autostart"
