DESCRIPTION = "Car dashboard demo application based on wxWidgets"

S = "${WORKDIR}/git/wxdashboard"

# WXwindows licence is a modified version of LGPL explicitly allowing not
# distributing the sources of an application using the library even in the
# case of static linking.
LICENSE = "WXwindows"
LIC_FILES_CHKSUM = "file://../licence.txt;md5=981f50a934828620b08f44d75db557c6"

DEPENDS += "wxwidgets"

RDEPENDS_${PN} += "weston-service"

SRCREV = "3b56572b91bd8b286d89d423c67a6f123e3e7be8"
SRC_URI = "git://github.com/varigit/wxwidgets-examples.git;branch=main;protocol=https"

do_install() {
	install -d ${D}${bindir}
	install -d ${D}${datadir}/wxDashBoard/images
	install -m 0755 wxDashBoard ${D}/${bindir}/
	install -m 0755 images/* ${D}${datadir}/wxDashBoard/images
	ln -s ${bindir}/wxDashBoard ${D}${bindir}/weston-app
}

FILES_${PN} += " \ 
	${datadir}/wxDashBoard/images/*  \
"
