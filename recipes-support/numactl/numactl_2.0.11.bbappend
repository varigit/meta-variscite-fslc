# oss.sgi.com archive is no longer available, switch to github
SRC_URI_remove = "ftp://oss.sgi.com/www/projects/libnuma/download/${BPN}-${PV}.tar.gz"
SRC_URI_prepend = "https://github.com/numactl/${BPN}/releases/download/v${PV}/${BPN}-${PV}.tar.gz "
