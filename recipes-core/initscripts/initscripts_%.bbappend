#
#Variscite init script Add-On
#

#PRINC := "${@int(PRINC) + 1}"

# look for files in the layer first
FILESEXTRAPATHS_prepend := "${THISDIR}:"

SRC_URI_append			= " file://variscite-bluetooth \
                                    file://variscite-touch \
				  "
#

SRC_URI_variscite-bluetooth[md5sum] = "5ec6845d84e20fb93ecd226104a961a8"


do_install_append() {
	if [ -e "${WORKDIR}/variscite-bluetooth" ]; then
		install -m 0755    ${WORKDIR}/variscite-bluetooth ${D}${sysconfdir}/init.d
		install -m 0755    ${WORKDIR}/variscite-touch ${D}${sysconfdir}/init.d
#		install -m 0755    ${WORKDIR}/variscite-alsa-init ${D}${sysconfdir}/init.d
		update-rc.d -r ${D} variscite-bluetooth start 99 2 3 4 5 .
		update-rc.d -r ${D} variscite-touch start 99 2 3 4 5 .
#		update-rc.d -r ${D} variscite-alsa-init start 02 S .
	fi
}

