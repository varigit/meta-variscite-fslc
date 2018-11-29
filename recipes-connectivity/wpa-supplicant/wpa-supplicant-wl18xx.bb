# This is a TI specific version of the wpa-supplicant recipe for use with the
# wl18xx wlan module.

require wpa-supplicant-wl18xx.inc

LICENSE = "GPLv2 | BSD"
LIC_FILES_CHKSUM = "file://../COPYING;md5=292eece3f2ebbaa25608eed8464018a3 \
                    file://../README;md5=3f01d778be8f953962388307ee38ed2b \
                    file://wpa_supplicant.c;beginline=1;endline=17;md5=35e6d71fea6b15f61a9fac935bcf410f"

FILESEXTRAPATHS_prepend := "${THISDIR}/wpa-supplicant-wl18xx:"

# Tag: R8.7_SP3
SRCREV = "ee8fbdb840d95e048f58fb62bf3b5472041b5417"
BRANCH = "upstream_25_rebase"

# Add ti to the PV to indicate that this is a TI modified version of wpa-supplicant.
PV = "R8.7_SP3-ti"

PROVIDES += "wpa-supplicant"
RPROVIDES_${PN}  += "wpa-supplicant"
RREPLACES_${PN}  += "wpa-supplicant"
RCONFLICTS_${PN}  += "wpa-supplicant"
RDEPENDS_${PN} += "wpa-supplicant-cli wpa-supplicant-passphrase"
