# Disable automatic control of matchbox-keyboard from matchbox desktop
RDEPENDS_${PN}-base_remove = "matchbox-keyboard-im"
# Remove gst-player
RDEPENDS_${PN}-apps_remove_imx7-var-som = "gst-player"
RDEPENDS_${PN}-apps_remove_imx6ul-var-som = "gst-player"
