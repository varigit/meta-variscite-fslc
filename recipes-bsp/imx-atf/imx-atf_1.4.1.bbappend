FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://0001-ATF-support-to-different-LPDDR4-configurations.patch \
	file://atf-0001-1-add-noc-tuning-smc-case-lower-cpu-vpu-memory-acces.patch \
"
