FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	file://0001-linuxfb-platform-plugin-add-rotation-support.patch \
"

BACKEND_FB = "linuxfb"
BACKEND_FB_imxgpu3d = "eglfs"
BACKEND = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xcb', \
	   bb.utils.contains('DISTRO_FEATURES', 'wayland', 'wayland', '${BACKEND_FB}', d), d)}"

# build linuxfb backend if required
PACKAGECONFIG_append = " fontconfig tslib ${@bb.utils.filter('BACKEND', 'linuxfb', d)}"

do_install_append () {
	if ${@bb.utils.contains('DISTRO','b2qt','false','true',d)}; then
		if [ "${BACKEND}" = "linuxfb" ]; then
			# this override eglfs for iMX6UL and iMX7
			echo "export QT_QPA_PLATFORM=${BACKEND}" >> ${D}${sysconfdir}/profile.d/qt5.sh
		elif [ "${BACKEND}" = "eglfs" ]; then
			echo "export QT_QPA_EGLFS_FORCEVSYNC=1" >> ${D}${sysconfdir}/profile.d/qt5.sh
		elif [ "${BACKEND}" = "xcb" ]; then
			echo "export DISPLAY=:0" >> ${D}${sysconfdir}/profile.d/qt5.sh
		fi
		if [ "${BACKEND_FB}" = "linuxfb" ]; then
			# allow using QML with SW rendering for iMX6UL and iMX7
			echo "export QMLSCENE_DEVICE=softwarecontext" >> ${D}${sysconfdir}/profile.d/qt5.sh
		else
			# enable multiple buffer for iMX6 and iMX8 families
			echo "export FB_MULTI_BUFFER=2" >> ${D}${sysconfdir}/profile.d/qt5.sh
		fi
		echo "export XDG_RUNTIME_DIR=/run/user" >> ${D}${sysconfdir}/profile.d/qt5.sh
	fi
}
