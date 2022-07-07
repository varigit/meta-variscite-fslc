# Copyright (C) 2022 Variscite
include freertos-variscite.inc

SRCREV = "400b111535768f7aad0b25d29b09b8a9b352cd5f"
# See https://github.com/varigit/freertos-variscite/blob/mcuxpresso_sdk_2.11.x-var01/docs/MCUXpresso%20SDK%20Release%20Notes%20for%20EVK-MIMX8MN.pdf
# "Development Tools" section for supported GCC version
CM_GCC = "gcc-arm-none-eabi-10.3-2021.07"

SRC_URI += " \
    git://github.com/varigit/freertos-variscite.git;protocol=https;branch=${MCUXPRESSO_BRANCH}; \
    https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.07/gcc-arm-none-eabi-10.3-2021.07-x86_64-linux.tar.bz2;name=gcc-arm-none-eabi-10.3-2021.07 \
"

SRC_URI[gcc-arm-none-eabi-10.3-2021.07.sha256sum] = "8c5b8de344e23cd035ca2b53bbf2075c58131ad61223cae48510641d3e556cea"

COMPATIBLE_MACHINE = "(imx8mn-var-som|imx8mm-var-dart|imx8mq-var-dart)"
