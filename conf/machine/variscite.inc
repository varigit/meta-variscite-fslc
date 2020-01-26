MACHINE_FEATURES += " pci bluetooth wifi"

PREFERRED_VERSION_linux-variscite = "4.19.35"

KERNEL_IMAGETYPE_mx8 = "Image.gz"

SOC_DEFAULT_WKS_FILE_mx8 = "imx-imx-boot-bootpart1.wks.in"

DEFAULTTUNE_mx8 = "aarch64"

PREFERRED_PROVIDER_u-boot-fw-utils = "u-boot-fw-utils"
PREFERRED_RPROVIDER_ptpd = "ptpd"
PREFERRED_RPROVIDER_ptpd-dev = "ptpd"

MACHINE_EXTRA_RDEPENDS += " \
	bcm43xx-utils \
	brcm-patchram-plus \
	gptfdisk \
	hostapd \
	hdparm \
	iw \
	kernel-modules \
	kmod \
	linux-firmware-bcm4339 \
	linux-firmware-bcm43430 \
	${@bb.utils.contains('DISTRO', 'b2qt', '', 'networkmanager', d)} \
	packagegroup-tools-bluetooth \
	pm-utils \
	rng-tools \
	wpa-supplicant \
	wireless-regdb-static \
	u-boot-fw-utils \
	u-boot-splash \
"

# Packages added to all images (including core-image-minimal)
IMAGE_INSTALL_append = " \
	kernel-image \
	kernel-devicetree \
"

IMAGE_FSTYPES = "tar.gz wic.gz"
