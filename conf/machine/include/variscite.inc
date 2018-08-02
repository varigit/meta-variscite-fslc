MACHINE_FEATURES += " pci bluetooth touchscreen wifi"

# UBIFS for Variscite 0.5GB NAND flash
# erase block size of 128KiB
export MKUBIFS_ARGS_128kbpeb = " -m 2048 -e 124KiB -c 3965 "
export UBINIZE_ARGS_128kbpeb = " -m 2048 -p 128KiB -s 2048 "

# erase block size of 256KiB
export MKUBIFS_ARGS_256kbpeb = " -m 4096 -e 248KiB -c 2000 "
export UBINIZE_ARGS_256kbpeb = " -m 4096 -p 256KiB -s 4096 "

# UBIFS for Variscite 1GB NAND flash
# erase block size of 128KiB
#MKUBIFS_ARGS = " -m 2048 -e 124KiB -c 7855 "
#UBINIZE_ARGS = " -m 2048 -p 128KiB -s 2048 "

# erase block size of 512KiB
#MKUBIFS_ARGS = " -m 4096 -e 504KiB -c 2000 "
#UBINIZE_ARGS = " -m 4096 -p 512KiB -s 4096 "

MULTIUBI_BUILD ?= "128kbpeb 256kbpeb"

UBI_VOLNAME  = "rootfs"

# Variscite BSP default providers
PREFERRED_PROVIDER_virtual/kernel ?= "linux-variscite"
PREFERRED_VERSION_linux-variscite = "4.9.11"

PREFERRED_PROVIDER_u-boot = "u-boot-variscite"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-variscite"
PREFERRED_PROVIDER_u-boot-fw-utils = "u-boot-fw-utils"

PREFERRED_PROVIDER_wpa-supplicant-cli = "wpa-supplicant"
PREFERRED_PROVIDER_wpa-supplicant-passphrase = "wpa-supplicant"
PREFERRED_PROVIDER_wpa-supplicant = "wpa-supplicant"

MACHINE_EXTRA_RDEPENDS += " \
			   crda \
			   bridge-utils \
			   connman \
			   hostapd \
			   imx-kobs \
			   iw \
			   kernel-modules \
			   packagegroup-tools-bluetooth \
			   pm-utils \
			   rng-tools \
			   hdparm \
			   gptfdisk \
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

WKS_FILE = "imx-uboot-spl-bootpart.wks"
IMAGE_FSTYPES += "tar.gz multiubi"

# do multiubi last
IMAGE_TYPEDEP_multiubi += "${IMAGE_FSTYPES}"
IMAGE_TYPEDEP_multiubi_remove = "multiubi"

multiubi_mkfs_prepend() {
	# Update PEB size in fw_env.config (u-boot-fw-utils)
	if [ -f ${IMAGE_ROOTFS}${sysconfdir}/fw_env.config ]; then
		# Get PEB from UBINIZE_ARGS
		MTD_ERASESIZE=`echo "$2" | tr ' =' '\n' | awk '/^-p$|^--peb-size$/{getline; print}'`
		# Convert to bytes (decimal)
		MTD_ERASESIZE=`echo $MTD_ERASESIZE | sed 's/MiB/ * 1024 KiB/;s/KiB/ * 1024/' | bc`
		# Convert to hexadecimal
		MTD_ERASESIZE=`printf 0x%x $MTD_ERASESIZE`

		awk -i inplace -v n=4 -v ERASESIZE="${MTD_ERASESIZE}" '/\/dev\/mtd/{$(n)=ERASESIZE}1' ${IMAGE_ROOTFS}${sysconfdir}/fw_env.config
	fi
}
