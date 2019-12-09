FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRCREV = "413e93e10ee4838e9a68b190f1468722f6385e0e"

SRC_URI += " \
	file://imx8mm-atf-uart4.patch \
	file://imx8mm-atf-ddr-timing.patch \
" 

