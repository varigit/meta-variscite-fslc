SUMMARY = "Bluetooth Audio ALSA Backend"
HOMEPAGE = "https://github.com/Arkq/bluez-alsa"
SECTION = "libs"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=72d868d66bdd5bf51fe67734431de057"

DEPENDS = "alsa-lib bluez5 dbus glib-2.0 sbc"
DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES','systemd',' systemd',' update-rc.d-native',d)}"

SRCREV = "deecd2cc76d22b40e49e81a41d0b856681a24217"
SRC_URI = " \
    git://github.com/Arkq/bluez-alsa.git;branch=master;protocol=https \
    file://bluez-alsa.service \
    file://bluez-alsa \
"

S = "${WORKDIR}/git"

inherit systemd pkgconfig autotools

do_install_append () {
  if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/bluez-alsa.service ${D}${systemd_unitdir}/system
    install -d ${D}${sysconfdir}/bluetooth
    install -m 0755 ${WORKDIR}/bluez-alsa ${D}${sysconfdir}/bluetooth
  else
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/bluez-alsa ${D}${sysconfdir}/init.d
    update-rc.d -r ${D} bluez-alsa defaults
  fi
}

FILES_${PN} += "${libdir}/alsa-lib/lib*.so ${datadir}/alsa"
FILES_${PN}-dev += "${libdir}/alsa-lib/*.la"
FILES_${PN}-staticdev += "${libdir}/alsa-lib/lib*.a"
FILES_${PN}-dbg += "${libdir}/alsa-lib/.debug/*.so"

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_${PN} = "bluez-alsa.service"
