RDEPENDS_bluez5 += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pulseaudio', \
        'pulseaudio \
         pulseaudio-server \
         pulseaudio-misc \
         pulseaudio-module-dbus-protocol \
         pulseaudio-module-cli \
         pulseaudio-module-device-manager \
         pulseaudio-lib-bluez5-util', \
        '', d)} \
"

