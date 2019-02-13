# Workaround to fix do_compile() failure due to missing fsl-imx8mq-evk.dtb
do_compile_prepend() {
	echo "Copying DTB"
        if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mq-var-dart.dtb ]; then
          cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mq-var-dart.dtb ${S}/iMX8M/fsl-imx8mq-evk.dtb
        fi
        if [ -f ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mm-var-dart.dtb ]; then
          cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mm-var-dart.dtb ${S}/iMX8M/fsl-imx8mm-evk.dtb
        fi
}
