# Copyright (C) 2021 Variscite
include freertos-variscite.inc

SRCREV = "fa71caba163f20b950506807fbc6ea43277fd2cb"
# See https://github.com/varigit/freertos-variscite/blob/mcuxpresso_sdk_2.8.x-var01/docs/MCUXpresso%20SDK%20Release%20Notes%20for%20EVK-MIMX8MN.pdf
# "Development Tools" section for supported GCC version
CM_GCC = "gcc-arm-none-eabi-9-2019-q4-major"

SRC_URI = " \
    git://github.com/varigit/freertos-variscite.git;protocol=git;branch=${MCUXPRESSO_BRANCH}; \
    https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2;name=gcc-arm-none-eabi-9-2019-q4-major \
"

SRC_URI[gcc-arm-none-eabi-9-2019-q4-major.sha256sum] = "bcd840f839d5bf49279638e9f67890b2ef3a7c9c7a9b25271e83ec4ff41d177a"

COMPATIBLE_MACHINE = "(imx8mn-var-som|imx8mm-var-dart|imx8mq-var-dart|imx8qm-var-som|imx8qxp-var-som|imx8qxpb0-var-som)"
