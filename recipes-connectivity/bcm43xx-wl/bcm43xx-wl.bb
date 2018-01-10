DESCRIPTION = "Configuration tool for WIFI adapters based on Broadcom/Cypress bcm43xx chipsets"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENCE;md5=3160c14df7228891b868060e1951dfbc"
 
RDEPENDS_${PN} = "libnl libnl-genl libnl-nf libnl-route"

S = "${WORKDIR}"

SRC_URI = " \
	file://wl \
	file://LICENCE \
"

do_install() {
        install -d -p ${D}/usr/bin
        install -m 0755 ${S}/wl ${D}/usr/bin
}

FILES_${PN} = "/usr/bin/*"

