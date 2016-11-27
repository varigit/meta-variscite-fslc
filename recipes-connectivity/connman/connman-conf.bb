SUMMARY = "Connman config to setup wired interface on qemu machines"
DESCRIPTION = "This is the ConnMan configuration to set up a Wired \
Wirless and Bluetooth network interface for a VAR-SOM-MX6 machine."
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI_append = " file://settings"

PR = "r2"

S = "${WORKDIR}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES_${PN} = "${localstatedir}/* ${libdir}/*"

do_install() {
        install -d ${D}${localstatedir}/lib/connman
        install -m 0644 ${WORKDIR}/settings ${D}${localstatedir}/lib/connman
}

COMPATIBLE_MACHINE = "(var-som-mx6)"
