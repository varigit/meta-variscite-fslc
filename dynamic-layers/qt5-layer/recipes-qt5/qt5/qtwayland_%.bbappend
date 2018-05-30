FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "\
	file://01-fix-compositor-build.patch \
	file://02-fix-compositor-build.patch \
"
