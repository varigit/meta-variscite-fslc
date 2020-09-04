# update URI upon git.freescale.com closure
SRC_URI = "${FSL_MIRROR}/firmware-imx-${PV}.bin;fsl-eula=true \
           git://github.com/NXP/imx-firmware.git;branch=${SRCBRANCH};destsuffix=${S}/git "

SRCREV = "f6d0859f9435796f03ae93b70b5f92f4406bc56d"
