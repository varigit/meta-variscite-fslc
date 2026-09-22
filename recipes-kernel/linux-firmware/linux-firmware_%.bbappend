# Support additional firmware for bc43xx and wl18xx WIFI+BT modules

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV_FORMAT = "linux-firmware"

BRCM_REV = "8.5.0.7"
SRC_URI[brcm_lwb.sha256sum] = "5a607bc3ca8cea619eae03efa2def406b813603751ffaf3c57c43d7874b4b34e"
SRC_URI[brcm_lwb5.sha256sum] = "221f1a552eb8d273fd0e169da873eb8a9610edc836ae2b026ebd4e7f82f4ffa2"

# TI WiFi FW 8.9.0.0.88 and BT FW 4.7
SRCREV_tiwlan = "bda5304cc86e9c4029f8101394d2a8b39c640f53"
BRANCH_tiwlan = "master"
SRCREV_tibt = "3aa1d75f3c2ae77f6e4d36194e3d281b899ab149"
BRANCH_tibt = "master"

# NXP WiFi
SRCREV_nxp_wifi = "d31ea8aaba67e188ba0071a90da0364e3946c83a"
BRANCH_nxp_wifi = "lf-6.12.20_2.0.0"

SRC_URI_append = " \
	https://github.com/LairdCP/Sterling-LWB-and-LWB5-Release-Packages/releases/download/LRD-REL-${BRCM_REV}/laird-lwb-fcc-firmware-${BRCM_REV}.tar.bz2;name=brcm_lwb \
	https://github.com/LairdCP/Sterling-LWB-and-LWB5-Release-Packages/releases/download/LRD-REL-${BRCM_REV}/laird-lwb5-fcc-firmware-${BRCM_REV}.tar.bz2;name=brcm_lwb5 \
	git://github.com/nxp-imx/imx-firmware.git;protocol=https;branch=${BRANCH_nxp_wifi};destsuffix=nxp-firmware;name=nxp_wifi \
	git://git.ti.com/git/wilink8-wlan/wl18xx_fw.git;protocol=https;branch=${BRANCH_tiwlan};destsuffix=tiwlan;name=tiwlan \
	git://git.ti.com/git/ti-bt/service-packs.git;protocol=https;branch=${BRANCH_tibt};destsuffix=tibt;name=tibt \
	file://wl1271-nvs.bin \
	file://var_wifi_mod_para.conf \
"

do_install_append() {
	install -d ${D}${nonarch_base_libdir}/firmware/bcm
	install -m 0755 ${WORKDIR}/lib/firmware/brcm/* ${D}${nonarch_base_libdir}/firmware/brcm/
	install -m 0755 ${WORKDIR}/tibt/initscripts/TIInit_*.bts ${D}${nonarch_base_libdir}/firmware/ti-connectivity
	install -m 0755 ${WORKDIR}/tiwlan/*.bin ${D}${nonarch_base_libdir}/firmware/ti-connectivity
	install -m 0755 ${WORKDIR}/wl1271-nvs.bin ${D}${nonarch_base_libdir}/firmware/ti-connectivity

	# Install NXP IW612 firmware and configuration
	install -d ${D}${nonarch_base_libdir}/firmware/nxp

	install -m 0644 \
		${WORKDIR}/nxp-firmware/nxp/FwImage_IW612_SD/sd_w61x_v1.bin.se \
		${WORKDIR}/nxp-firmware/nxp/FwImage_IW612_SD/sduart_nw61x_v1.bin.se \
		${WORKDIR}/nxp-firmware/nxp/FwImage_IW612_SD/uartspi_n61x_v1.bin.se \
		${WORKDIR}/nxp-firmware/nxp/FwImage_IW612_SD/uartuart_n61x_v1.bin.se \
		${D}${nonarch_base_libdir}/firmware/nxp/

	install -m 0644 ${WORKDIR}/nxp-firmware/nxp/mfguart/helper_uart_3000000.bin ${D}${nonarch_base_libdir}/firmware/nxp/
	install -m 0644 ${WORKDIR}/var_wifi_mod_para.conf ${D}${nonarch_base_libdir}/firmware/nxp/wifi_mod_para.conf
}

PACKAGES =+ " \
  ${PN}-nxp-common \
  ${PN}-nxpiw612-sdio \
"

FILES_${PN}-bcm4339 += " \
  ${nonarch_base_libdir}/firmware/brcm/BCM4335C0.hcd \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4339-sdio.txt \
"

FILES_${PN}-bcm43430 += " \
  ${nonarch_base_libdir}/firmware/brcm/BCM43430A1.hcd \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt \
"

FILES_${PN}-nxpiw612-sdio += " \
  ${nonarch_base_libdir}/firmware/nxp/sd_w61x_v1.bin.se \
  ${nonarch_base_libdir}/firmware/nxp/sduart_nw61x_v1.bin.se \
  ${nonarch_base_libdir}/firmware/nxp/uartspi_n61x_v1.bin.se \
  ${nonarch_base_libdir}/firmware/nxp/uartuart_n61x_v1.bin.se \
"

FILES_${PN}-nxp-common = " \
  ${nonarch_base_libdir}/firmware/nxp/wifi_mod_para.conf \
  ${nonarch_base_libdir}/firmware/nxp/helper_uart_3000000.bin \
"
