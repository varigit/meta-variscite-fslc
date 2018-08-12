DESCRIPTION = "Firmware files for use with TI wl18xx"
LICENSE = "TI-TSPA"
LIC_FILES_CHKSUM = "file://wlan/LICENCE;md5=4977a0fe767ee17765ae63c435a32a9e"

inherit allarch

PV = "R8.7_SP3"

# TI WiFi FW 8.9.0.0.79
SRCREV_wlan = "d153edae2a75393937da43159b7e6251c2cd01b6"
BRANCH_wlan = "master"
SRCREV_bt = "0ee619b598d023fffc77679f099bc2a4815510e4"
BRANCH_bt = "master"
SRC_URI = " \
	   git://git.ti.com/wilink8-wlan/wl18xx_fw.git;protocol=git;branch=${BRANCH_wlan};destsuffix=wlan;name=wlan \
	   git://git.ti.com/ti-bt/service-packs.git;protocol=git;branch=${BRANCH_bt};destsuffix=bt;name=bt \
	   file://wl1271-nvs.bin \
	   "

S = "${WORKDIR}"

do_install() {
	install -d -p ${D}/lib/firmware/ti-connectivity
	install -m 0755 bt/initscripts/TIInit_*.bts ${D}/lib/firmware/ti-connectivity
	install -m 0755 wlan/*.bin ${D}/lib/firmware/ti-connectivity
	install -m 0644 wlan/LICENCE ${D}/lib/firmware/ti-connectivity
	install -m 0755 ${S}/wl1271-nvs.bin ${D}/lib/firmware/ti-connectivity
}

FILES_${PN} = "/lib/firmware/ti-connectivity/*"
