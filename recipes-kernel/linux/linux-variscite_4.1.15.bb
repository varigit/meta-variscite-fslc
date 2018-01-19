#@DESCRIPTION: Linux for Variscite i.MX boards
#
# http://www.variscite.com

require recipes-kernel/linux/linux-imx.inc
require recipes-kernel/linux/linux-dtb.inc

DEPENDS += "lzop-native bc-native"

# Do not copy the kernel image to the rootfs by default
RDEPENDS_kernel-base = ""

LOCALVERSION_var-som-mx6 = "-mx6"
LOCALVERSION_imx6ul-var-dart = "-mx6ul"
LOCALVERSION_imx7-var-som = "-mx7"

SRCBRANCH = "imx-rel_imx_4.1.15_2.0.0_ga-var02"
SRCBRANCH_imx6ul-var-dart = "imx-rel_imx_4.1.15_2.0.0_ga-var03"
SRCREV = "9fe9500c07bfda0cc871dbf5beac9b06ce99896f"
SRCREV_imx6ul-var-dart = "2504b634d632ec3d718881be9e230bc5e7b822f2"
KERNEL_SRC ?= "git://github.com/varigit/linux-2.6-imx.git;protocol=git"
SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH}"

DEFAULT_PREFERENCE = "1"

KERNEL_DEFCONFIG_var-som-mx6 = "${S}/arch/arm/configs/imx_v7_var_defconfig"
KERNEL_DEFCONFIG_imx6ul-var-dart = "${S}/arch/arm/configs/imx6ul-var-dart_defconfig"
KERNEL_DEFCONFIG_imx7-var-som = "${S}/arch/arm/configs/imx7-var-som_defconfig"

do_preconfigure_prepend() {
   cp ${KERNEL_DEFCONFIG} ${WORKDIR}/defconfig
}

do_merge_delta_config() {
    # copy desired defconfig so we pick it up for the real kernel_do_configure
    cp ${KERNEL_DEFCONFIG} ${B}/.config

    # add config fragments
    for deltacfg in ${DELTA_KERNEL_DEFCONFIG}; do
        if [ -f "${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m ${B}/.config ${deltacfg}
        elif [ -f "${WORKDIR}/${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m ${B}/.config ${WORKDIR}/${deltacfg}
        elif [ -f "${S}/arch/${ARCH}/configs/${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m ${B}/.config \
                ${S}/arch/${ARCH}/configs/${deltacfg}
        fi
    done
    mv ${B}/.config ${WORKDIR}/defconfig
}

do_configure_prepend_imx6ul-var-dart() {
   # Disable WIFI support, relevant code is built from external tree
   kernel_conf_variable CFG80211 n
}

do_configure_prepend_imx7-var-som() {
   # Disable WIFI support, relevant code is built from external tree
   kernel_conf_variable CFG80211 n
}

COMPATIBLE_MACHINE = "(var-som-mx6|imx6ul-var-dart|imx7-var-som)"

do_merge_delta_config[dirs] = "${B}"

addtask merge_delta_config before do_preconfigure after do_patch
