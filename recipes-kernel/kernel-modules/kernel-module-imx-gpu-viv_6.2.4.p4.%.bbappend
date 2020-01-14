FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_imx8mm-var-dart = " \
	file://0001-gpu-imx-Enable-GPU-driver-workaround-for-i.MX8M-Mini.patch \
"

SRC_URI_append_imx8mn-var-som = " \
        file://0001-gpu-imx-Enable-GPU-driver-workaround-for-i.MX8M-Nano.patch \
"
 
