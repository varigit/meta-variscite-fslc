generate_imx_sdcard_mx8 () {
        # Create partition table
        parted -s ${SDCARD} mklabel msdos
        parted -s ${SDCARD} unit KiB mkpart primary ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${IMAGE_ROOTFS_ALIGNMENT} \+ $ROOTFS_SIZE)
        parted ${SDCARD} print

        # Burn bootloader
        dd if=${DEPLOY_DIR_IMAGE}/imx-boot-${MACHINE}-${UBOOT_CONFIG}.bin of=${SDCARD} conv=notrunc seek=${IMX_BOOT_SEEK} bs=1K

        # Burn root partition
        dd if=${SDCARD_ROOTFS} of=${SDCARD} conv=notrunc,fsync seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024)
}

