FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
	file://0001-www-sync-web-app-in-examples.patch \
	file://0001-web-app-remove-limit-on-fileSize-for-dropzone.patch \
	file://0001-Update-index.html-Fixed-typos-and-improved-text.patch \
	file://0001-examples-website-synchronize-with-web-app-sources.patch \
"
