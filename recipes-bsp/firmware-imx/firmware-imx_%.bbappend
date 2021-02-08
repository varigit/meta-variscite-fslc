do_install_append() {
	install -d ${D}/boot
	mv ${D}${nonarch_base_libdir}/firmware/imx/hdmi/hdmitxfw.bin ${D}/boot
	mv ${D}${nonarch_base_libdir}/firmware/imx/hdmi/hdmirxfw.bin ${D}/boot
	mv ${D}${nonarch_base_libdir}/firmware/imx/hdmi/dpfw.bin ${D}/boot
	rm -rf ${D}${nonarch_base_libdir}/firmware/imx/hdmi
	install -m 0644 ${S}/firmware/vpu/vpu_fw_imx8_dec.bin ${D}${nonarch_base_libdir}/firmware/vpu
	install -m 0644 ${S}/firmware/vpu/vpu_fw_imx8_enc.bin ${D}${nonarch_base_libdir}/firmware/vpu
}

FILES_${PN}-hdmi += "/boot/"
