#Variscite init script Add-On

FILESEXTRAPATHS_prepend := "${THISDIR}:"

SRC_URI_append = " file://variscite-bluetooth \
		   file://variscite-touch \
		   file://variscite-pwrkey"

do_install_append() {
	install -m 0755 ${WORKDIR}/variscite-bluetooth ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/variscite-touch ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/variscite-pwrkey ${D}${sysconfdir}/init.d
	update-rc.d -r ${D} variscite-bluetooth start 99 2 3 4 5 .
	update-rc.d -r ${D} variscite-touch start 99 2 3 4 5 .
	update-rc.d -r ${D} variscite-pwrkey start 99 2 3 4 5 .
}

