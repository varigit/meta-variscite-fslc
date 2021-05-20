FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " \
	file://0001-psplash-Change-colors-for-the-Variscite-Yocto-logo.patch \
	file://psplash-bar.png \
"
SPLASH_IMAGES = "file://psplash-poky.png;outsuffix=default"

do_configure_prepend() {
	cp ${WORKDIR}/*.png ${S}/base-images
}

INITSCRIPT_PARAMS = "start 0 S . stop 21 0 1 6 ."
