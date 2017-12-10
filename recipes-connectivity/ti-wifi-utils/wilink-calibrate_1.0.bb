LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

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
