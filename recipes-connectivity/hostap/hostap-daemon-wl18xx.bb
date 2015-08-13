# This is a TI specific version of the hostap-daemon recipe for use with the
# wl18xx wlan and bluetooth module.

require hostap.inc

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://../COPYING;md5=ab87f20cd7e8c0d0a6539b34d3791d0e"

PR_append = "c"

FILESEXTRAPATHS_append := "${THISDIR}/hostap-daemon:"

# Add TI to the end to make it clear that this is a TI customized version
# of hostap
PV = "R8.5-devel-ti+git${SRCPV}"

# Tag: R8.5
SRCREV = "2710d0ae31fa2dc31f653f346a985268d8d7795c"
BRANCH = "ap_p2p"

PROVIDES += "hostap-daemon"
RPROVIDES_${PN} += "hostap-daemon"
RREPLACES_${PN} += "hostap-daemon"
RCONFLICTS_${PN} += "hostap-daemon"
