# Copyright (C) 2014 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Package group for Qt5 demos"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} += " \
    qtsmarthome \
    qt5ledscreen \
    quitbattery \
    qt5everywheredemo \
    qt5nmapcarousedemo \
    qt5nmapper \
    cinematicexperience \
    quitindicators \
    qt5-demo-extrafiles \
"
