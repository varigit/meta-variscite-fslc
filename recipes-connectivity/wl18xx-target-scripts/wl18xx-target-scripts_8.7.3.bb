DESCRIPTION = "Scripts and configuration files for TI wireless drivers"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=21;md5=b8d6a0865f50159bf5c0d175d1f4a705"

# Tag: R8.7_SP3 (8.7.3)
SRCREV = "a07b6e711d2a70608101d3d6cdc5749c4d8a96d5"
BRANCH = "sitara-scripts"
SRC_URI = "git://git.ti.com/wilink8-wlan/wl18xx-target-scripts.git;protocol=git;branch=${BRANCH} \
file://0001-print_stat.sh-replace-system-bin-sh-with-bin-sh.patch \
"

PR = "r1"

S = "${WORKDIR}/git"

FILES_${PN} += "${datadir}/wl18xx/"

do_install() {
	install -d ${D}${datadir}/wl18xx/

	scripts=`find ./* -type f -name "*.*"`
	for s in $scripts
	do
		install -m 0755 $s ${D}${datadir}/wl18xx/
	done
}
