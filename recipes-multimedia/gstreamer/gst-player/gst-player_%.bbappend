SRC_URI_append = "file://gst-player_var.desktop"

do_install_append() {
        install -m 0644 -D ${WORKDIR}/gst-player_var.desktop ${D}${datadir}/applications/gst-player.desktop
}
