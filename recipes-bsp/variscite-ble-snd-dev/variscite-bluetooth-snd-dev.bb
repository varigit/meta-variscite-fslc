# Copyright (C) 2016 Variscite

DESCRIPTION = "Demo scripts for bluetooth a2pd"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PV = "0.1"

S = "${WORKDIR}"

SRC_URI = " \
	file://bluetooth-snd-server.sh \
	file://Readme.txt \
"

RDEPENDS_${PN} += " \
	pulseaudio \
    pulseaudio-server \
    pulseaudio-misc \
    pulseaudio-module-dbus-protocol \
    pulseaudio-module-cli \
    pulseaudio-module-device-manager \
    pulseaudio-lib-bluez5-util \
    pulseaudio-module-bluez5-discover \
    pulseaudio-module-bluez5-device \
    pulseaudio-module-bluetooth-policy \
    pulseaudio-module-bluetooth-discover \
"

do_install() {
	install -d ${D}/opt
	install -d ${D}/opt/var-bluetooth-snd-dev
	install -m 0755 ${S}/bluetooth-snd-server.sh ${D}/opt/var-bluetooth-snd-dev/
	install -m 0444 ${S}/Readme.txt ${D}/opt/var-bluetooth-snd-dev/
}

FILES_${PN} = " \
	/opt \
	/opt/var-bluetooth-snd-dev/* \
"
