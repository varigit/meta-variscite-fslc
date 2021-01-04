FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imx8mn-var-som = " file://imx-mkimage-imx8m-soc.mak-add-var-som-imx8m-nano-support.patch"
SRC_URI_append_imx8mq-var-dart = " file://imx-mkimage-imx8m-soc.mak-add-dart-mx8m-support.patch"
SRC_URI_append_imx8mm-var-dart = " file://imx-mkimage-imx8m-soc.mak-add-variscite-imx8mm-suppo.patch"

do_compile_prepend() {
	echo "Copying DTBs"
	if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mm-var-som-symphony.dtb ]; then
		cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mm-var-som-symphony.dtb ${S}/iMX8M/
	fi
}
