DESCRIPTION = "Freescale Image - Adds Qt5"
LICENSE = "MIT"

require fsl-image-gui.bb

inherit distro_features_check

CONFLICT_DISTRO_FEATURES = "directfb"

# Install Freescale QT demo applications
QT5_IMAGE_INSTALL_APPS = ""
QT5_IMAGE_INSTALL_APPS_mx6q = "${@bb.utils.contains("MACHINE_GSTREAMER_1_0_PLUGIN", "imx-gst1.0-plugin", "imx-qtapplications", "", d)}"
QT5_IMAGE_INSTALL_APPS_mx6dl = "${@bb.utils.contains("MACHINE_GSTREAMER_1_0_PLUGIN", "imx-gst1.0-plugin", "imx-qtapplications", "", d)}"

QT5_FONTS = " \
    ttf-dejavu-mathtexgyre \
    ttf-dejavu-sans \
    ttf-dejavu-sans-condensed \
    ttf-dejavu-sans-mono \
    ttf-dejavu-serif \
    ttf-dejavu-serif-condensed \
    "
# Install Freescale QT demo applications for X11 backend only
#
MACHINE_QT5_MULTIMEDIA_APPS = ""
QT5_IMAGE_INSTALL = ""
QT5_IMAGE_INSTALL_common = " \
    packagegroup-qt5-toolchain-target \
    packagegroup-qt5-demos \
    qtbase \
    qtbase-plugins \
    ${QT5_FONTS} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'libxkbcommon', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'qtwayland qtwayland-plugins', \
       bb.utils.contains('DISTRO_FEATURES',     'x11', '${QT5_IMAGE_INSTALL_APPS}', \
                                                       '', d), d)} \
"
QT5_IMAGE_INSTALL_mx6 = " \
    ${QT5_IMAGE_INSTALL_common} \
    qtwebkit \
    qtwebkit-examples \
    qt3d \
    qt3d-qmlplugins \
    qt3d-tools \
    "
QT5_IMAGE_INSTALL_mx6ul = "${QT5_IMAGE_INSTALL_common}"
QT5_IMAGE_INSTALL_mx7 = "${QT5_IMAGE_INSTALL_common}"

QT5_IMAGE_INSTALL_mx8 = " \
    ${QT5_IMAGE_INSTALL_common} \
    gstreamer1.0-plugins-bad-qt \
    "
# Add packagegroup-qt5-webengine to QT5_IMAGE_INSTALL_mx6 and comment out the line below to install qtwebengine to the rootfs.
QT5_IMAGE_INSTALL_remove = " packagegroup-qt5-webengine"

IMAGE_INSTALL += " \
${QT5_IMAGE_INSTALL} \
"
