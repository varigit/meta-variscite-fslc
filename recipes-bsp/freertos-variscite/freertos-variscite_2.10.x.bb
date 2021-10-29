# Copyright (C) 2021 Variscite
include freertos-variscite.inc

SRCREV = "db2c47b339ab5ccaa923d4bc3de3a5222439fc15"
# See https://github.com/varigit/freertos-variscite/blob/mcuxpresso_sdk_2.10.x-var01/docs/MCUXpresso%20SDK%20Release%20Notes%20for%20EVK-MIMX8MN.pdf
# "Development Tools" section for supported GCC version
CM_GCC = "gcc-arm-none-eabi-10-2020-q4-major"

SRC_URI += " \
    git://github.com/varigit/freertos-variscite.git;protocol=git;branch=${MCUXPRESSO_BRANCH}; \
    https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2;name=gcc-arm-none-eabi-10-2020-q4-major \
"

SRC_URI[gcc-arm-none-eabi-10-2020-q4-major.sha256sum] = "21134caa478bbf5352e239fbc6e2da3038f8d2207e089efc96c3b55f1edcd618"

COMPATIBLE_MACHINE = "(imx8mn-var-som|imx8mm-var-dart|imx8mq-var-dart)"
