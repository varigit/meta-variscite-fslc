# This is a TI specific version of the hostap-daemon recipe for use with the
# wl18xx wlan module

HOMEPAGE = "http://hostap.epitest.fi"
DESCRIPTION = "User space daemon for extended IEEE 802.11 management"
SECTION = "kernel/userland"

DEPENDS = "libnl openssl"

# Since this is a TI customized version of hostap-daemon do not make this the
# default
DEFAULT_PREFERENCE = "-1"

PR = "r6"

inherit update-rc.d
INITSCRIPT_NAME="hostapd"

CONFFILES_${PN} += "${sysconfdir}/hostapd.conf"

SRC_URI = "git://git.ti.com/wilink8-wlan/hostap.git;protocol=git;branch=${BRANCH} \
           file://defconfig \
	       file://init"

S = "${WORKDIR}/git/hostapd"

do_configure() {
	install -m 0644 ${WORKDIR}/defconfig ${S}/.config
	echo "CFLAGS += -I${STAGING_INCDIR}" >> .config
        echo "CFLAGS += -I${STAGING_INCDIR}/libnl3/" >> .config
	echo "LIBS += -L${STAGING_LIBDIR}" >> .config
}

do_compile() {
	make
}

do_install() {
	install -d ${D}${sbindir} ${D}${sysconfdir}/init.d
	install -m 0644 ${S}/hostapd.conf ${D}${sysconfdir}
	install -m 0755 ${S}/hostapd ${D}${sbindir}
	install -m 0755 ${S}/hostapd_cli ${D}${sbindir}
	install -m 755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/hostapd
}

# The default hostapd.conf file that is fetched from upstream is using
# "a" band which is not supported by the 1271 chip.
# modify it to use "g" band and default channel 6 and change the ssid from
# "test" to a more meaningful name.

updatercd_postinst () {
:
}

