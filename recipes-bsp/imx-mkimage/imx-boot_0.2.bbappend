# Workaround to fix do_compile() failure due to missing fsl-imx8mq-evk.dtb
do_compile_prepend() {
   echo "Checking Target"
   if [ "${SOC_TARGET}" = "iMX8M" ]; then
	echo "Copying DTB"
        cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/imx8m-var-dart.dtb ${S}/${SOC_TARGET}/fsl-imx8mq-evk.dtb
   fi
}
