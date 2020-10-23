FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_imx8mn-var-som = " file://imx-mkimage-imx8m-soc.mak-add-var-som-imx8m-nano-support.patch"
SRC_URI_append_imx8mq-var-dart = " file://imx-mkimage-imx8m-soc.mak-add-dart-mx8m-support.patch"

do_compile_prepend() {
	echo "Copying DTBs"
	if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mm-var-som.dtb ]; then
		cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mm-var-som.dtb ${S}/iMX8M/
	fi

	if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mm-var-som-rev10.dtb ]; then
		cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mm-var-som-rev10.dtb ${S}/iMX8M/
	fi

	if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mn-var-som-rev10.dtb ]; then
		cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8mn-var-som-rev10.dtb ${S}/iMX8M/
	fi
}
