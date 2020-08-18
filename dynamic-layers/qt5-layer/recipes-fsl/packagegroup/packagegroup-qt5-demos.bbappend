# always add qml demos even for not accelererated platforms (SW rendering)
RDEPENDS_${PN}_append = " \
    cinematicexperience \
    qt5everywheredemo \ 
    qt5nmapper \
    qt5nmapcarousedemo \
    qtsmarthome \
    quitbattery \
"
