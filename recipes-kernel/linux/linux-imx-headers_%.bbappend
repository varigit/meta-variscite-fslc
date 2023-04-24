# Migrate source code from codeaurora to github
SRC_URI_remove = "git://source.codeaurora.org/external/imx/linux-imx.git;protocol=https;branch=${SRCBRANCH}"
SRC_URI_prepend = "git://github.com/nxp-imx/linux-imx.git;protocol=https;branch=${SRCBRANCH}"

