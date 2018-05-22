PACKAGECONFIG_append = " accessibility examples linuxfb tslib fontconfig"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

BACKEND_FB = "linuxfb"
BACKEND_FB_imxgpu3d = "eglfs"
BACKEND = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xcb', \
	   bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '${BACKEND_FB}', d), d)}"

SRC_URI_append = "\
	file://01-fix-eglfs_viv-integration.patch \
"

do_install_append () {
	install -d ${D}${sysconfdir}/profile.d/
	echo "#!/bin/sh" >> ${D}${sysconfdir}/profile.d/qt5.sh
	echo "export QT_QPA_PLATFORM=${BACKEND}" >> ${D}${sysconfdir}/profile.d/qt5.sh
	if [ "${BACKEND}" = "eglfs" ]; then
		echo "export QT_QPA_EGLFS_FORCEVSYNC=1" >> ${D}${sysconfdir}/profile.d/qt5.sh
	elif [ "${BACKEND_FB}" = "linuxfb" ]; then
		echo "export QMLSCENE_DEVICE=softwarecontext" >> ${D}${sysconfdir}/profile.d/qt5.sh
	fi
	chmod 0755 ${D}${sysconfdir}/profile.d/qt5.sh
}
