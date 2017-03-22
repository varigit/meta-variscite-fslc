DESCRIPTION = "Firmware files for use with TI wl18xx"
LICENSE = "TI-TSPA"
LIC_FILES_CHKSUM = "file://wlan/LICENCE;md5=4977a0fe767ee17765ae63c435a32a9e"

inherit allarch

PV = "R8.7_SP1"

# Tag: R8.7 SP1
SRCREV_wlan = "fe3909e93d15a4b17e43699dde2bba0e9a3c0abc"
BRANCH_wlan = "master"
SRCREV_bt = "54f5c151dacc608b19ab2ce4c30e27a3983048b2"
BRANCH_bt = "master"
SRC_URI = " \
	   git://git.ti.com/wilink8-wlan/wl18xx_fw.git;protocol=git;branch=${BRANCH_wlan};destsuffix=wlan;name=wlan \
	   git://git.ti.com/ti-bt/service-packs.git;protocol=git;branch=${BRANCH_bt};destsuffix=bt;name=bt \
	   "

S = "${WORKDIR}"

do_install() {
	install -d -p ${D}/lib/firmware/ti-connectivity
	install -m 0755 bt/initscripts/*.bts ${D}/lib/firmware/ti-connectivity
	install -m 0755 wlan/*.bin ${D}/lib/firmware/ti-connectivity
	install -m 0644 wlan/LICENCE ${D}/lib/firmware/ti-connectivity
	ln -sf /lib/firmware/ti-connectivity/wl18xx-fw-4.bin ${D}/lib/firmware/ti-connectivity/wl1271-nvs.bin
}

FILES_${PN} = "/lib/firmware/ti-connectivity/*"
