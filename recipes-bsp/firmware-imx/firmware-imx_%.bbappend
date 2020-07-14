do_install_append() {
	install -d ${D}/boot
	mv ${D}${base_libdir}/firmware/imx/hdmi/hdmitxfw.bin ${D}/boot
	mv ${D}${base_libdir}/firmware/imx/hdmi/hdmirxfw.bin ${D}/boot
	mv ${D}${base_libdir}/firmware/imx/hdmi/dpfw.bin ${D}/boot
	rm -rf ${D}${base_libdir}/firmware/imx/hdmi
}

FILES_${PN}-hdmi += "/boot/"
