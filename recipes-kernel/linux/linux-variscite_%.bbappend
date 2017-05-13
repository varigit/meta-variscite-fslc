do_install_append() {
    # Delete unused kernel image in rootfs (under /boot/)
    rm -rf ${D}/boot/${KERNEL_IMAGETYPE}-${KERNEL_VERSION} || true;
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

do_merge_delta_config[dirs] = "${B}"

addtask merge_delta_config before do_preconfigure after do_patch
