FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SC_FIRMWARE_NAME_imx8qxp-var-som = "mx8qx-var-som-scfw-tcm.bin"

SRC_URI += " \
	file://${SC_FIRMWARE_NAME} \
"

do_deploy_prepend() {
    cp ${WORKDIR}/${SC_FIRMWARE_NAME} ${S}
}


