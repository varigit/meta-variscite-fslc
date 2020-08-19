DESCRIPTION = "A fsl-image-gui image with docker-ce support"
LICENSE = "MIT"

require recipes-fsl/images/fsl-image-gui.bb

inherit distro_features_check

REQUIRED_DISTRO_FEATURES += "virtualization"

IMAGE_INSTALL += " \
    docker-ce \
    python3-docker-compose \
"
