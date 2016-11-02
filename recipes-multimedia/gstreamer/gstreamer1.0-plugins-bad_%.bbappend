PACKAGECONFIG_append += " \
	${@bb.utils.contains('DISTRO_FEATURES', 'x11', "gtk", "", d)} \
"