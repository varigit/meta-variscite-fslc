FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://atf_disable_ddr_setup.patch \
	file://atf-0001-1-add-noc-tuning-smc-case-lower-cpu-vpu-memory-acces.patch \
"
