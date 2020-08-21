MACHINE_FEATURES += " pci bluetooth wifi"

PREFERRED_VERSION_linux-variscite = "5.4.24"

KERNEL_IMAGETYPE_mx8 = "Image.gz"

SOC_DEFAULT_WKS_FILE_mx8 = "imx-imx-boot-bootpart1.wks.in"

DEFAULTTUNE_mx8mm  ?= "cortexa53-crypto"
DEFAULTTUNE_mx8mn  ?= "cortexa53-crypto"
DEFAULTTUNE_mx8mq  ?= "cortexa53-crypto"
DEFAULTTUNE_mx8qxp ?= "cortexa35-crypto"

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
	${@bb.utils.contains('DISTRO', 'b2qt', '', \
           bb.utils.contains('DISTRO_FEATURES', 'wayland', 'networkmanager', \
                                                       '', d), d)} \
	packagegroup-tools-bluetooth \
	pm-utils \
	rng-tools \
	wpa-supplicant \
	wireless-regdb-static \
	u-boot-fw-utils \
	u-boot-splash \
"

# Packages added to all images (including core-image-minimal)
IMAGE_INSTALL_append_mx8 = " \
	kernel-image \
	kernel-devicetree \
"

IMAGE_FSTYPES = "tar.gz wic.gz"
