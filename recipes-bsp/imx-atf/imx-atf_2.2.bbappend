FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://imx8m-Disable-ATF-console_imx_uart_register-for.patch"
SRC_URI_append = " file://imx8m-atf-ddr-timing.patch"
SRC_URI_append = " file://0001-plat-imx8m-Fix-the-suspend-resume-hang-issue-on-imx8.patch"
SRC_URI_append = " file://0001-MLK-24721-plat-imx8m-Fix-the-out-of-bound-access-to-.patch"
SRC_URI_append_imx8mm-var-dart = " file://imx8mm-atf-uart4.patch"
SRC_URI_append_imx8mn-var-som  = " file://imx8mn-atf-uart4.patch"

SRCREV = "06450210f94c10e7298804bcc6498955769ec907"
