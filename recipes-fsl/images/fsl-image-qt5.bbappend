# Due to the QT samples the resulting image will not fit the default NAND size.
# Removing default ubi creation for this image
# For production consider to edit UBINIZE_ARGS in conf/machine/var-som-mx6.conf and remove this file
IMAGE_FSTYPES_remove = "ubi"