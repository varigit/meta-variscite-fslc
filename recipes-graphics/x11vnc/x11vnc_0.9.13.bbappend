FILESEXTRAPATHS_append := "${THISDIR}/${PN}:"

SRC_URI_append = "file://remove-redundant-RPATH.patch"
