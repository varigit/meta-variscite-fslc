PACKAGECONFIG_append = " accessibility examples linuxfb tslib fontconfig"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "\
	file://01-fix-eglfs_viv-integration.patch \
"
