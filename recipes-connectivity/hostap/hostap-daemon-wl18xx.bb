# This is a TI specific version of the hostap-daemon recipe for use with the
# wl18xx wlan and bluetooth module.

require hostap.inc

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://../COPYING;md5=36b27801447e0662ee0138d17fe93880"

PR_append = "d"

FILESEXTRAPATHS_append := ":${THISDIR}/hostap-daemon"

# Add TI to the end to make it clear that this is a TI customized version
# of hostap
PV = "R8.6-devel-ti+git${SRCPV}"

# Tag: R8.6
SRCREV = "f80fe345acf103ba6882ac8396f19584ac184904"
BRANCH = "upstream_24"

PROVIDES += "hostap-daemon"
RPROVIDES_${PN} += "hostap-daemon"
RREPLACES_${PN} += "hostap-daemon"
RCONFLICTS_${PN} += "hostap-daemon"
