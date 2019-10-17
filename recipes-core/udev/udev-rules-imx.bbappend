FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_imx8mq-var-dart = " file://usb-power.rules"
SRC_URI_append_imx8mm-var-dart = " file://usb-power.rules"

do_install_append_imx8mq-var-dart () {
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/usb-power.rules ${D}${sysconfdir}/udev/rules.d/
}

do_install_append_imx8mm-var-dart () {
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/usb-power.rules ${D}${sysconfdir}/udev/rules.d/
}

