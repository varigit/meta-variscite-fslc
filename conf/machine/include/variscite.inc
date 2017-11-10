MACHINE_FEATURES += " pci bluetooth touchscreen wifi"

# UBIFS for Variscite NAND 0.5 GB
MKUBIFS_ARGS = " -m 2048 -e 124KiB -c 3965 "
UBINIZE_ARGS = " -m 2048 -p 128KiB -s 2048 -O 2048 "

# UBIFS for Variscite NAND 1.0 GB (models with erase block size of 128KiB)
#MKUBIFS_ARGS = " -m 2048 -e 124KiB -c 7855 "
#UBINIZE_ARGS = " -m 2048 -p 128KiB -s 2048 -O 2048 "

# UBIFS for Variscite NAND 1.0 GB (models with erase block size of 512KiB)
#MKUBIFS_ARGS = " -m 4096 -e 504KiB -c 2000 "
#UBINIZE_ARGS = " -m 4096 -p 512KiB -s 4096 -O 4096 "

UBI_VOLNAME  = "rootfs"

# Variscite BSP default providers
PREFERRED_PROVIDER_virtual/kernel ?= "linux-variscite"
PREFERRED_VERSION_linux-variscite = "4.9.11"

PREFERRED_PROVIDER_u-boot = "u-boot-variscite"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-variscite"

PREFERRED_PROVIDER_wpa-supplicant-cli = "wpa-supplicant"
PREFERRED_PROVIDER_wpa-supplicant-passphrase = "wpa-supplicant"
PREFERRED_PROVIDER_wpa-supplicant = "wpa-supplicant"

MACHINE_EXTRA_RDEPENDS += " \
			   bridge-utils \
			   connman \
			   hostapd \
			   imx-kobs \
			   iw \
			   kernel-modules \
			   packagegroup-tools-bluetooth \
			   pm-utils \
			   rng-tools \
			   tslib-calibrate \
			   tslib-tests \
			   u-boot-fw-utils \
			   u-boot-splash \
			   wpa-supplicant \
			   ${@bb.utils.contains('DISTRO_FEATURES', 'x11', "x11vnc", "", d)} \
			   "

# Packages added to all images (including core-image-minimal)
IMAGE_INSTALL_append = " \
        fsl-rc-local \
"

BBMASK_prepend = "fsl-image-mfgtool-initramfs "
BBMASK += "meta-freescale/dynamic-layers/browser-layer/recipes-browser/chromium"

IMAGE_FSTYPES = "tar.gz ext4 sdcard ubi"
