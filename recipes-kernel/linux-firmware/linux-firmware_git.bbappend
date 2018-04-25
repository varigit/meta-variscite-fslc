do_install_append() {
	# we prefer using those provided by wl18xx-firmware recipe
	rm ${D}/lib/firmware/ti-connectivity/wl18xx-fw-4.bin
	rm ${D}/lib/firmware/ti-connectivity/wl1271-nvs.bin
}
