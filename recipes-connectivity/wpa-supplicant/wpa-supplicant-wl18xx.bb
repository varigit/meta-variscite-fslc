# This is a TI specific version of the wpa-supplicant recipe for use with the
# wl18xx wlan module.

require wpa-supplicant.inc

LICENSE = "GPLv2 | BSD"
LIC_FILES_CHKSUM = "file://../COPYING;md5=ab87f20cd7e8c0d0a6539b34d3791d0e \
                    file://../README;md5=ba46b65db36e3c82244a3815b3738d63 \
                    file://wpa_supplicant.c;beginline=1;endline=17;md5=8835156c8ab8cad6356ec7f39ebe3aba"

FILESEXTRAPATHS_append := "${THISDIR}/wpa-supplicant:"

# Tag: R8.5
SRCREV = "2710d0ae31fa2dc31f653f346a985268d8d7795c"
BRANCH = "ap_p2p"
PR_append = "c"

# Add ti to the PV to indicate that this is a TI modify version of wpa-supplicant.
PV = "R8.5-devel-ti+git${SRCPV}"

PROVIDES += "wpa-supplicant"
RPROVIDES_${PN}  += "wpa-supplicant"
RREPLACES_${PN}  += "wpa-supplicant"
RCONFLICTS_${PN}  += "wpa-supplicant"
RDEPENDS_${PN} += "wpa-supplicant-cli wpa-supplicant-passphrase"
