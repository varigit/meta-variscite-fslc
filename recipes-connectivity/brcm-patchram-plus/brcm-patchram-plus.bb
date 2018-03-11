#@DESCRIPTION: Variscite brcm_patchram_plus network apps"
#
# http://www.variscite.com

PR = "r0"
LICENSE = "GPLv2"

S = "${WORKDIR}"

LIC_FILES_CHKSUM = "file://brcm_patchram_plus.c;md5=ba2645ee8a6f2fab1a237b59b4923b9a"
SRC_URI = "file://brcm_patchram_plus.c"

do_compile() {
        ${CC} ${CFLAGS} ${LDFLAGS} -o brcm_patchram_plus brcm_patchram_plus.c
}

do_install() {
        install -d ${D}${bindir}/
        install -m 0755 ${S}/brcm_patchram_plus ${D}${bindir}/
}

FILES_${PN} = "${bindir}/brcm_patchram_plus"
