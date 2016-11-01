DESCRIPTION = "Firmware files for use with TI wl18xx"
LICENSE = "TI-TSPA"
LIC_FILES_CHKSUM = "file://LICENCE;md5=4977a0fe767ee17765ae63c435a32a9e"

inherit allarch

PV = "R8.6_SP1"

PROVIDES += "wl12xx-firmware"
RPROVIDES_${PN} += "wl12xx-firmware"
RREPLACES_${PN} += "wl12xx-firmware"
RCONFLICTS_${PN} += "wl12xx-firmware"

# Tag: R8.7 SP1
SRCREV = "fe3909e93d15a4b17e43699dde2bba0e9a3c0abc"
BRANCH = "master"
SRC_URI = "git://git.ti.com/wilink8-wlan/wl18xx_fw.git;protocol=git;branch=${BRANCH} \
           file://0001-Add-Makefile-for-SDK.patch \
          "
#
#Variscite Firmware
#
SRC_URI += "https://github.com/varigit/BT_VAR_FW/archive/yocto_v5.zip"
SRC_URI[md5sum] = "92fc8ec04bb3297d74a06c01e5f542bb"
SRC_URI[sha256sum] = "e0c39f1e7960b2f8034ce23fe3e6ce50fb4648478f25f1d1efe1ea2865b01840"


S = "${WORKDIR}/git"

do_compile() {
    :
}

do_install() {
    oe_runmake 'DEST_DIR=${D}' install
#add Variscite Firmware
	cp -r ../BT_VAR_FW-yocto_v5/* ${D}/lib/firmware/ti-connectivity
}

FILES_${PN} = "/lib/firmware/ti-connectivity/*"
