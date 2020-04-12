DESCRIPTION = "A console-only image with docker support"
LICENSE = "MIT"

inherit core-image distro_features_check

REQUIRED_DISTRO_FEATURES += "virtualization"

IMAGE_FEATURES += "splash ssh-server-dropbear"

IMAGE_INSTALL += " \
    docker \
    python3-docker-compose \
    packagegroup-basic \
    packagegroup-core-full-cmdline \
    alsa-utils \
    curl \
    dosfstools \
    fio \
    i2c-tools \
    imx-kobs \
    ldd \
    memtester \
    mtd-utils \
    mtd-utils-ubifs \
"
