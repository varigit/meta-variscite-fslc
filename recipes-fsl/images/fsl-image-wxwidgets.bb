DESCRIPTION = "Freescale Image - Add wxWidgets"
LICENSE = "MIT"

require recipes-fsl/images/fsl-image-gui.bb

IMAGE_INSTALL += " \
	g++-symlinks \
	gcc-symlinks \
	m4 \
	make \
	gdk-pixbuf \
	gdk-pixbuf-bin \
	gtk+3-dev \
	gtk+3-demo \
	wxwidgets \
	wxwidgets-dev \
	wxwidgets-samples \
	wxdashboard \
"

