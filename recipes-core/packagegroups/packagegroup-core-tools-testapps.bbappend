# Disable building the LTP package to keep the rootfs small
RDEPENDS_${PN}_remove = "ltp"
# Remove gst-player
X11TOOLS_remove_imx6ul-var-dart = "gst-player"
X11TOOLS_remove_imx7-var-som = "gst-player"
