# Migrate source code from codeaurora to github
SRC_URI_remove = "git://source.codeaurora.org/external/imx/xf86-video-imx-vivante.git;protocol=https;branch=${SRCBRANCH}"
SRC_URI_prepend = "git://github.com/nxp-imx/xf86-video-imx-vivante.git;protocol=https;branch=${SRCBRANCH}"

