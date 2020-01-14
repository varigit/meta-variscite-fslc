FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://imx8mm-atf-uart4.patch \
	file://imx8mn-atf-uart4.patch \
	file://imx8mm-atf-ddr-timing.patch \
" 

