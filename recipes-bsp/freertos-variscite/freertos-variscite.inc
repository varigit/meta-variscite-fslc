# Copyright (C) 2021 Variscite
DESCRIPTION = "Variscite i.MX Cortex M4/M7 Firmware Demos"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYING-BSD-3;md5=0858ec9c7a80c4a2cf16e4f825a2cc91"
SECTION = "BSP"

SRC_URI = " \
    file://variscite-rproc-linux \
    file://variscite-rproc-u-boot \
    file://variscite-rproc-common.sh \
    file://variscite-rproc.conf \
"

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

# If remoteproc is used to reload ddr firmware, special disable_cache firmware
# must be reloaded between stop and start comments
# For Example:
#   echo cm_rpmsg_lite_pingpong_rtos_linux_remote.elf.ddr_debug > /sys/class/remoteproc/remoteproc0/firmware
#   echo start > /sys/class/remoteproc/remoteproc0/state
#   echo stop > /sys/class/remoteproc/remoteproc0/state

#   echo cm_disable_cache.elf.debug > /sys/class/remoteproc/remoteproc0/firmware
#   echo start > /sys/class/remoteproc/remoteproc0/state
#   echo stop > /sys/class/remoteproc/remoteproc0/state

#   echo cm_rpmsg_lite_str_echo_rtos_imxcm4.elf.ddr_debug > /sys/class/remoteproc/remoteproc0/firmware
#   echo start > /sys/class/remoteproc/remoteproc0/state
#   echo stop > /sys/class/remoteproc/remoteproc0/state
CM_DEMOS_DISABLE_CACHE = ""
CM_DEMOS_DISABLE_CACHE_mx8qxp = "demo_apps/disable_cache"
CM_DEMOS_DISABLE_CACHE_mx8qm = "demo_apps/disable_cache/cm4_core0 demo_apps/disable_cache/cm4_core1"

DISABLE_CACHE_PATCH="disable_cache.patch"
DISABLE_CACHE_PATCH_imx8qxp-var-som="disable_cache_${PV}.patch"
DISABLE_CACHE_PATCH_imx8qxpb0-var-som="disable_cache_${PV}.patch"
SRC_URI_append_imx8qxp-var-som += "file://${DISABLE_CACHE_PATCH};apply=no"
SRC_URI_append_imx8qxpb0-var-som += "file://${DISABLE_CACHE_PATCH};apply=no"
SRC_URI_append_imx8qm-var-som += "file://${DISABLE_CACHE_PATCH};apply=no"

compile_fw() {
    DIR_GCC="$1"
    cd ${DIR_GCC}
    ./clean.sh
    ./build_all.sh > /dev/null
}

do_compile() {
    # Configure ARMGCC
    export ARMGCC_DIR="${WORKDIR}/${CM_GCC}"

    # Copy and patch hello_world demo to disable_cache demo
    if [ -e "${WORKDIR}/${DISABLE_CACHE_PATCH}" ]; then
        # Copy hello_world demo
        cp -r ${S}/boards/${CM_BOARD}/demo_apps/hello_world/ ${S}/boards/${CM_BOARD}/demo_apps/disable_cache
        # Rename hello_world strings to disable_cache
        grep -rl hello_world ${S}/boards/${CM_BOARD}/demo_apps/disable_cache | xargs sed -i 's/hello_world/disable_cache/g'
        # Rename hello_world files to disable_cache
        find ${S}/boards/${CM_BOARD}/demo_apps/disable_cache/ -name '*hello_world*' -exec sh -c 'mv "$1" "$(echo "$1" | sed s/hello_world/disable_cache/)"' _ {} \;
    fi

    # Build all demos in CM_DEMOS
    for CM_DEMO in ${CM_DEMOS}; do
        compile_fw "${S}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
    done

    # Build firmware to reset cache
    if [ -e "${WORKDIR}/${DISABLE_CACHE_PATCH}" ]; then
        # Apply patch to disable cache for machine
        cd ${S} && git apply ${WORKDIR}/${DISABLE_CACHE_PATCH}

        # Build the firmware
        for CM_DEMO in ${CM_DEMOS_DISABLE_CACHE}; do
                compile_fw "${S}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
        done
    fi
}

do_install() {
    readonly CM_BUILD_TARGETS=" \
        debug \
        ddr_debug \
    "

    # Install scripts
    install -d ${D}${sysconfdir}/remoteproc
    install -m 0755 ${WORKDIR}/variscite-rproc-u-boot ${D}${sysconfdir}/remoteproc
    install -m 0755 ${WORKDIR}/variscite-rproc-linux ${D}${sysconfdir}/remoteproc
    install -m 0644 ${WORKDIR}/variscite-rproc-common.sh ${D}${sysconfdir}/remoteproc
    install -m 0644 ${WORKDIR}/variscite-rproc.conf ${D}${sysconfdir}/remoteproc

    # Install firmware
    install -d ${D}${nonarch_base_libdir}/firmware/
    install -d ${D}/boot/

    # Install all demos in CM_DEMOS
    for CM_DEMO in ${CM_DEMOS}; do
        DIR_GCC="${S}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
        # Install all build targets
        for CM_BUILD_TARGET in ${CM_BUILD_TARGETS}; do
            # Install elf
            FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.elf)"
            install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${D}${nonarch_base_libdir}/firmware/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}

            # Install bin
            FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.bin)"
            install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${D}/boot/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}
        done
    done

    # Install disable_cache demos (all demos in CM_DEMOS_DISABLE_CACHE)
    for CM_DEMO in ${CM_DEMOS_DISABLE_CACHE}; do
        DIR_GCC="${S}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
        # Install all build targets
        CM_BUILD_TARGET="debug"
        # Install elf
        FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.elf)"
        install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${D}${nonarch_base_libdir}/firmware/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}
    done
}

FILES_${PN} = " \
	${sysconfdir}/remoteproc \
	${nonarch_base_libdir}/firmware \
	/boot \
"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# Firmware files are run on M4/M7
INSANE_SKIP = "arch"
