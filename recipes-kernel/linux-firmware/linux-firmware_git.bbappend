# Support additional firmware for WiLink8 & LAIRD modules

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV_FORMAT = "linux-firmware"

# TI WiFi FW 8.9.0.0.79
SRCREV_tiwlan = "d153edae2a75393937da43159b7e6251c2cd01b6"
BRANCH_tiwlan = "master"
SRCREV_tibt = "31a43dc1248a6c19bb886006f8c167e2fd21cb78"
BRANCH_tibt = "master"
SRCREV_brcm = "7bce9b69b51ffd967176c1597feed79305927370"
BRANCH_brcm = "6.0.0.121"
SRC_URI_append = " \
	   git://git.ti.com/wilink8-wlan/wl18xx_fw.git;protocol=git;branch=${BRANCH_tiwlan};destsuffix=tiwlan;name=tiwlan \
	   git://git.ti.com/ti-bt/service-packs.git;protocol=git;branch=${BRANCH_tibt};destsuffix=tibt;name=tibt \
	   file://wl1271-nvs.bin \
	   git://github.com/varigit/bcm_4343w_fw.git;protocol=git;branch=${BRANCH_brcm};destsuffix=brcm;name=brcm \
"

do_install_append() {
	install -m 0755 ${WORKDIR}/tibt/initscripts/TIInit_*.bts ${D}${nonarch_base_libdir}/firmware/ti-connectivity
	install -m 0755 ${WORKDIR}/tiwlan/*.bin ${D}${nonarch_base_libdir}/firmware/ti-connectivity
	install -m 0755 ${WORKDIR}/wl1271-nvs.bin ${D}${nonarch_base_libdir}/firmware/ti-connectivity
	install -d ${D}${nonarch_base_libdir}/firmware/bcm
	install -m 0755 ${WORKDIR}/brcm/brcm/* ${D}${nonarch_base_libdir}/firmware/brcm/
	install -m 0755 ${WORKDIR}/brcm/*.hcd ${D}${nonarch_base_libdir}/firmware/bcm
}

FILES_${PN}-bcm4339 += " \
  ${nonarch_base_libdir}/firmware/bcm/bcm4339.hcd \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac4339-sdio.txt \
"

FILES_${PN}-bcm43430 += " \
  ${nonarch_base_libdir}/firmware/bcm/bcm43430a1.hcd \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.txt \
  ${nonarch_base_libdir}/firmware/brcm/brcmfmac43430-sdio.clm_blob \
"
