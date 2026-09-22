require nxp-wlan-sdk_git.inc

SUMMARY = "NXP Wi-Fi SDK"

RDEPENDS_${PN} = "iw"

do_compile[noexec] = "1"

do_install () {
    install -d ${D}${datadir}/nxp_wireless

    install -m 0644 README ${D}${datadir}/nxp_wireless
}

FILES_${PN} = "${datadir}/nxp_wireless"

COMPATIBLE_MACHINE = "(imx)"
