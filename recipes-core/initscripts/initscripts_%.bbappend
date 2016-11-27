#Variscite init script Add-On

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
                  file://variscite-bluetooth \
                  file://variscite-pwrkey \
	          "
SRC_URI_append_var-som-mx6 = " file://variscite-touch"

do_install_append() {
	install -m 0755 ${WORKDIR}/variscite-bluetooth ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/variscite-pwrkey ${D}${sysconfdir}/init.d
	update-rc.d -r ${D} variscite-bluetooth start 99 2 3 4 5 .
	update-rc.d -r ${D} variscite-pwrkey start 99 2 3 4 5 .
}

do_install_append_var-som-mx6() {
	install -m 0755 ${WORKDIR}/variscite-touch ${D}${sysconfdir}/init.d
	update-rc.d -r ${D} variscite-touch start 99 2 3 4 5 .
}
