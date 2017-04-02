# This is a TI specific version of the wpa-supplicant recipe for use with the
# wl18xx wlan module.

require wpa-supplicant.inc

LICENSE = "GPLv2 | BSD"
LIC_FILES_CHKSUM = "file://../COPYING;md5=36b27801447e0662ee0138d17fe93880 \
                    file://../README;md5=7f393579f8b109fe91f3b9765d26c7d3 \
                    file://wpa_supplicant.c;beginline=1;endline=17;md5=8a3131126465e08eb6b8d17ea880e162"

FILESEXTRAPATHS_prepend := "${THISDIR}/wpa-supplicant:"

# Tag: R8.6_SP1
SRCREV = "dfb9d310814f0b7449c25fad87a8f1fa7ba8313e"
BRANCH = "upstream_24"

# Add ti to the PV to indicate that this is a TI modify version of wpa-supplicant.
PV = "R8.6_SP1-ti"

PROVIDES += "wpa-supplicant"
RPROVIDES_${PN}  += "wpa-supplicant"
RREPLACES_${PN}  += "wpa-supplicant"
RCONFLICTS_${PN}  += "wpa-supplicant"
RDEPENDS_${PN} += "wpa-supplicant-cli wpa-supplicant-passphrase"
