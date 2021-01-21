FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SC_FIRMWARE_NAME_imx8qxp-var-som = "mx8qx-var-som-scfw-tcm.bin"
SC_FIRMWARE_NAME_imx8qm-var-som = "mx8qm-var-som-scfw-tcm.bin"

SC_MX_FAMILY ?= "INVALID"
SC_MX8_FAMILY_mx8qm = "qm"
SC_MX8_FAMILY_mx8qxp = "qx"
SC_MACHINE_NAME = "mx8${SC_MX8_FAMILY}_b0"

SCFW_BRANCH = "1.5.1"
SRCREV = "495e846a5e1ff5d4208c2fb6529397d80c40ebf7"

SRC_URI += " \
    git://github.com/varigit/imx-sc-firmware.git;protocol=git;branch=${SCFW_BRANCH}; \
    https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2;name=gcc-arm-none-eabi \
"

SRC_URI[gcc-arm-none-eabi.md5sum] = "f55f90d483ddb3bcf4dae5882c2094cd"
SRC_URI[gcc-arm-none-eabi.sha256sum] = "fb31fbdfe08406ece43eef5df623c0b2deb8b53e405e2c878300f7a1f303ee52"

unset do_compile[noexec]

do_compile() {
    export TOOLS=${WORKDIR}
    cd ${WORKDIR}/git/src/scfw_export_${SC_MACHINE_NAME}/
    oe_runmake clean-${SC_MX8_FAMILY}
    oe_runmake ${SC_MX8_FAMILY} R=B0 B=var_som V=1
    cp ${WORKDIR}/git/src/scfw_export_${SC_MACHINE_NAME}/build_${SC_MACHINE_NAME}/scfw_tcm.bin ${S}/${SC_FIRMWARE_NAME}
}
