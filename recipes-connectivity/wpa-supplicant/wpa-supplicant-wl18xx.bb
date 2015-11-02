# This is a TI specific version of the wpa-supplicant recipe for use with the
# wl18xx wlan module.

require wpa-supplicant.inc

LICENSE = "GPLv2 | BSD"
LIC_FILES_CHKSUM = "file://../COPYING;md5=36b27801447e0662ee0138d17fe93880 \
                    file://../README;md5=7f393579f8b109fe91f3b9765d26c7d3 \
                    file://wpa_supplicant.c;beginline=1;endline=17;md5=8a3131126465e08eb6b8d17ea880e162"

FILESEXTRAPATHS_append := ":${THISDIR}/wpa-supplicant"

# Tag: R8.6
SRCREV = "f80fe345acf103ba6882ac8396f19584ac184904"
BRANCH = "upstream_24"
PR_append = "a"

# Add ti to the PV to indicate that this is a TI modify version of wpa-supplicant.
PV = "R8.6-devel-ti+git${SRCPV}"

PROVIDES += "wpa-supplicant"
RPROVIDES_${PN}  += "wpa-supplicant"
RREPLACES_${PN}  += "wpa-supplicant"
RCONFLICTS_${PN}  += "wpa-supplicant"
RDEPENDS_${PN} += "wpa-supplicant-cli wpa-supplicant-passphrase"
