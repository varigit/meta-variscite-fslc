# Copyright (C) 2015 Freescale Semiconductor
# Copyright 2017 NXP
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Package group for Qt5 webkit and examples"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} += " \
    qtwebkit \
    qtwebkit-qmlplugins \
"
