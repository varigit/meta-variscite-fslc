# Support additional firmware for bc43xx WIFI+BT modules

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRCREV_FORMAT = "linux-firmware"

SRCREV_brcm = "423be46b06b5629e45a4943f98a3053c819091ce"
BRANCH_brcm = "3.5.5.18"
SRC_URI_append = " \
           git://github.com/varigit/bcm_4343w_fw.git;protocol=git;branch=${BRANCH_brcm};destsuffix=brcm;name=brcm \
"
do_install_append() {
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
"

