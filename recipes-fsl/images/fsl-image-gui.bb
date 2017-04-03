# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Freescale Image to validate i.MX machines. \
This image contains everything used to test i.MX machines including GUI, \
demos and lots of applications. This creates a very large image, not \
suitable for production."
LICENSE = "MIT"

inherit core-image distro_features_check

### WARNING: This image is NOT suitable for production use and is intended
###          to provide a way for users to reproduce the image used during
###          the validation process of i.MX BSP releases.

IMAGE_FEATURES += " \
    splash \
    package-management \
    ssh-server-dropbear \
    hwcodecs \
    debug-tweaks \
    nfs-server \
    tools-debug \
    tools-testapps \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '', \
       bb.utils.contains('DISTRO_FEATURES',     'x11', 'x11-base x11-sato', \
                                                       '', d), d)} \
"

CORE_IMAGE_EXTRA_INSTALL += " \
	packagegroup-core-full-cmdline \
	packagegroup-tools-bluetooth \
	packagegroup-imx-tools-audio \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	packagegroup-fsl-tools-testapps \
	packagegroup-fsl-tools-benchmark \
	packagegroup-fsl-gstreamer1.0 \
	packagegroup-fsl-gstreamer1.0-full \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-init', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland xterm', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xterm', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'packagegroup-core-x11-sato-games', '', d)} \
	nodejs \
	flex \
	gcc \
	git \
	m4 \
	make \
	iperf \
	libtool \
	python-compiler \
	strace \
	screen \
	minicom \
	openssl \
"
