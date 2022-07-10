PACKAGECONFIG_append = " \
    ${@bb.utils.contains_any('DISTRO_FEATURES', d.getVar('GTK3DISTROFEATURES'), 'gstreamer', '', d)} \
    ${@bb.utils.contains_any('DISTRO_FEATURES', d.getVar('GTK3DISTROFEATURES'), 'webkit', '', d)} \
"
