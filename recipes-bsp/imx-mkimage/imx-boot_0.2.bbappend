# Workaround to fix do_compile() failure due to missing fsl-imx8mq-evk.dtb
do_compile_prepend() {
   if [ "${SOC_TARGET}" = "iMX8M" ]; then
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8m-var-dart.dtb ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/fsl-imx8mq-evk.dtb
   fi
}
