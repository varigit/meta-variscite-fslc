FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
        file://soc.mak \
"

do_compile_prepend() {
	echo "Copying soc.mak"
	cp ${WORKDIR}/soc.mak ${S}/iMX8M

	echo "Copying DTBs"
	if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mm-var-som.dtb ]; then
		cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mm-var-som.dtb ${S}/iMX8M/
	fi

	if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mm-var-som-rev10.dtb ]; then
		cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mm-var-som-rev10.dtb ${S}/iMX8M/
	fi

       if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mn-var-som-rev10.dtb ]; then
                cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mn-var-som-rev10.dtb ${S}/iMX8M/
       fi
}
