FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RDEPENDS_${PN}_append = " adwaita-icon-theme adwaita-icon-theme-cursors"

# [Shell] is already uncommented by default in Variscite's weston.ini
INI_UNCOMMENT_ASSIGNMENTS_remove_mx8mq = " \
    \\[shell\\] \
"
