# Copyright (C) 2015 Freescale Semiconductor
# Copyright 2017 NXP
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Package group for Qt5 3d and examples"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} += " \
    qt3d \
    qt3d-examples \
    qt3d-plugins \
    qt3d-qmlplugins \
    qt3d-tools \
"
