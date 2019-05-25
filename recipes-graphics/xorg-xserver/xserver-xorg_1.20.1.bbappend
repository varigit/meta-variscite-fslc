FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_mx6 = " file://0003-Remove-check-for-useSIGIO-option.patch"
