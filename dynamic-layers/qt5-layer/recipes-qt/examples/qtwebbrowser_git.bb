DESCRIPTION = "Qt Web Browser"
LICENSE = "GPL-3.0 | The-Qt-Company-Commercial"
LIC_FILES_CHKSUM = "file://LICENSE.GPLv3;md5=a40e2bb02b1ac431f461afd03ff9d1d6"

inherit qmake5
require recipes-qt/qt5/qt5.inc
require recipes-qt/qt5/qt5-git.inc

QT_GIT_PROJECT = "qt-apps"
QT_MODULE_BRANCH = "dev"

SRCREV = "09d629199fa153ea7954321d81f647d5eb52fb6c"

DEPENDS = "qtbase qtdeclarative qtwebengine"
RDEPENDS_${PN} = "qtvirtualkeyboard"

do_install_append() {
	install -d ${D}${datadir}/${PN}
	mv ${D}/data/user/qt/qtwebbrowser-app/* ${D}${datadir}/${PN}
	rm -rf ${D}/data
}

FILES_${PN} += "${datadir}/${PN}"
FILES_${PN}-dbg += "${datadir}/${PN}/.debug"
