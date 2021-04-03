FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
            file://0020-logind.conf-Set-HandlePowerKey-to-ignore.patch \
            file://0001-units-add-dependencies-to-avoid-conflict-between-con.patch \
"
