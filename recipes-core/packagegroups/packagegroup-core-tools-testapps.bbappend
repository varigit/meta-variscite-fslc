# Disable building the LTP package to keep the rootfs small
RDEPENDS_${PN}_remove = "ltp"
