# Copyright (C) 2021 Variscite
DESCRIPTION = "Variscite i.MX Cortex M4/M7 Firmware Demos"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING-BSD-3;md5=0858ec9c7a80c4a2cf16e4f825a2cc91"
SECTION = "BSP"

# inherit cmake
DEPENDS = "cmake-native"

S = "${WORKDIR}/git"

MCUXPRESSO_BRANCH = "mcuxpresso_sdk_${PV}-var01"

CM_BOARD="INVALID"
CM_BOARD_mx8mn="som_mx8mn"
CM_BOARD_mx8mq="dart_mx8mq"
CM_BOARD_mx8mm="dart_mx8mm"
CM_BOARD_mx8qm="som_mx8qm"
CM_BOARD_mx8qxp="som_mx8qx"

# Firmware source directories
CM_DEMOS = " \
    multicore_examples/rpmsg_lite_str_echo_rtos \
    multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote \
    demo_apps/hello_world \
"

# Firmware source directories
CM_DEMOS_mx8qm = " \
    multicore_examples/rpmsg_lite_str_echo_rtos/cm4_core0 \
    multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote/cm4_core0 \
    demo_apps/hello_world/cm4_core0 \
    multicore_examples/rpmsg_lite_str_echo_rtos/cm4_core1 \
    multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote/cm4_core1 \
    demo_apps/hello_world/cm4_core1 \
"

do_compile() {
    # Configure ARMGCC
    export ARMGCC_DIR="${WORKDIR}/${CM_GCC}"

    # Build all demos in CM_DEMOS
    for CM_DEMO in ${CM_DEMOS}; do
        DIR_GCC="${S}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
        cd ${DIR_GCC}
        ./clean.sh
        ./build_all.sh > /dev/null
    done
}

do_install() {
    readonly CM_BUILD_TARGETS=" \
        debug \
        ddr_debug \
    "

    install -d ${D}/lib/firmware/
    install -d ${D}/boot/

    # Install all demos in CM_DEMOS
    for CM_DEMO in ${CM_DEMOS}; do
        DIR_GCC="${S}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
        # Install all build targets
        for CM_BUILD_TARGET in ${CM_BUILD_TARGETS}; do
            # Install elf
            FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.elf)"
            install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${D}/lib/firmware/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}

            # Install bin
            FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.bin)"
            install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${D}/boot/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}
        done
    done
}

FILES_${PN} = " \
	/lib/firmware \
	/boot \
"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# Firmware files are run on M4/M7
INSANE_SKIP = "arch"
