IMAGE_INSTALL += " \
	android-tools \
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '', \
	   bb.utils.contains('DISTRO_FEATURES', 'x11', 'xterm', '', d), d)} \
"
