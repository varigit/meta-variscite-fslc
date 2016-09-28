LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

S = "${WORKDIR}"

SRC_URI = "file://runonkeyrls.c"

do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} -o runonkeyrls runonkeyrls.c
}

do_install() {
	install -d ${D}${bindir}/
	install -m 0755 ${S}/runonkeyrls ${D}${bindir}/
}
