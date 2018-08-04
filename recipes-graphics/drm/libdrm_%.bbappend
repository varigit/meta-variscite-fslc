FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imxgpu2d = " file://drm-update-arm.patch"

SRCREV = "afcebc08d60f45328c93d3f65604a16064f5e24a"

PACKAGE_ARCH_imxgpu2d = "${MACHINE_SOCARCH}"
