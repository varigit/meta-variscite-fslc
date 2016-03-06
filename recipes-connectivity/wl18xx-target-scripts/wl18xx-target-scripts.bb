DESCRIPTION = "Scripts and configuration files for TI wireless drivers"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=21;md5=b8d6a0865f50159bf5c0d175d1f4a705"

PV = "R8.6_SP1"

# Tag: R8.6_SP1
SRCREV = "693f71c709abcaa9047835cf3903aea26a63fa94"
BRANCH = "sitara-scripts"
SRC_URI = "git://git.ti.com/wilink8-wlan/wl18xx-target-scripts.git;protocol=git;branch=${BRANCH}"

SRC_URI_append = " file://fix_shell.patch"

S = "${WORKDIR}/git"

FILES_${PN} += "${datadir}/wl18xx/"

do_install() {
	install -d ${D}${datadir}/wl18xx/

	scripts=`find ${S} -type f -name "*.*" ! -path "${S}/.git/*" ! -path "${S}/.pc/*"`
	for s in $scripts
	do
		install -m 0755 $s ${D}${datadir}/wl18xx/
	done
}
