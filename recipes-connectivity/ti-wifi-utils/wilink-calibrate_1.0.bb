LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58"

inherit update-rc.d
INITSCRIPT_NAME="calibrate.sh"
INITSCRIPT_PARAMS = "start 20 2 3 4 5 ."

PR ="r0"

SRC_URI = "file://calibrate.sh"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/calibrate.sh ${D}${sysconfdir}/init.d
}
