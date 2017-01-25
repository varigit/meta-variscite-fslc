do_install_append() {
    # Delete unused kernel image in rootfs (under /boot/)
    rm -rf ${D}/boot/${KERNEL_IMAGETYPE}-${KERNEL_VERSION} || true;
}
