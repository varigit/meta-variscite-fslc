DESCRIPTION = "Freescale Image - Adds Qt5"
LICENSE = "MIT"

require recipes-fsl/images/fsl-image-gui.bb

inherit features_check populate_sdk_qt5

CONFLICT_DISTRO_FEATURES = "directfb"

# Install fonts
QT5_FONTS = " \
    ttf-dejavu-mathtexgyre \
    ttf-dejavu-sans \
    ttf-dejavu-sans-condensed \
    ttf-dejavu-sans-mono \
    ttf-dejavu-serif \
    ttf-dejavu-serif-condensed \
"

# Install QT5 demo applications
QT5_IMAGE_INSTALL = " \
    packagegroup-qt5-demos \
    ${QT5_FONTS} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'libxkbcommon', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'qtwayland qtwayland-plugins', '', d)} \
"

QT5_IMAGE_INSTALL_append_imxgpu3d = " \
    packagegroup-qt5-3d \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'packagegroup-qt5-webkit', '', d)} \
"

# Most of QtWebEngine demo are currently broken.
# If you want to test them uncomment the following line
# QT5_IMAGE_INSTALL_append_imxgpu3d = " packagegroup-qt5-webengine"

IMAGE_INSTALL += " \
    ${QT5_IMAGE_INSTALL} \
    qtserialbus \
"

# Due to the Qt samples the resulting image will not fit the default NAND size.
# Removing default ubi creation for this image
IMAGE_FSTYPES_remove = "multiubi"
