FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI_append = " file://0001-psplash-Change-colors-for-the-Variscite-Yocto-logo.patch"

INITSCRIPT_PARAMS = "start 0 S . stop 21 0 1 6 ."
