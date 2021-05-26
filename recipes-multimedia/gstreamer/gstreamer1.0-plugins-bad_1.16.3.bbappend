# opengl support for machines without GPU (mx6ul/mx7) is provided via mesa only for x11 distro
PACKAGECONFIG_REMOVE_IF_NOT_GPU = "${@bb.utils.contains('DISTRO_FEATURES', 'x11', '', 'gl', d)}"
PACKAGECONFIG_REMOVE_IF_NOT_GPU_imxgpu = ""
PACKAGECONFIG_remove = " \
    ${PACKAGECONFIG_REMOVE_IF_NOT_GPU} \
"
