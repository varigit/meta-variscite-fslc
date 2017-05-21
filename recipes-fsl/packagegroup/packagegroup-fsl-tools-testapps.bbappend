# Add can-utils

RDEPENDS_${PN} += " \
    imx-kobs \
    vlan \
    cryptodev-module \
    cryptodev-tests \
    procps \
    ptpd \
    linuxptp \
    iw \
    can-utils \
    cpufrequtils \
    nano \
    ntpdate \
    minicom \
    coreutils \
    mmc-utils \
    udev-extraconf \
    tslib-calibrate \
    tslib-tests \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'tk', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-examples', '', d)} \
"
