do_install_append() {
	rm -rf ${D}${nonarch_base_libdir}/firmware/brcm
}

FILES_${PN}_remove += "${nonarch_base_libdir}/firmware/brcm/*"

