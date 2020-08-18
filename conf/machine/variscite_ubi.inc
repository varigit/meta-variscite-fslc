# UBIFS for Variscite 0.5GB NAND flash
# erase block size of 128KiB
export MKUBIFS_ARGS_128kbpeb = " -m 2048 -e 124KiB -c 3965 "
export UBINIZE_ARGS_128kbpeb = " -m 2048 -p 128KiB -s 2048 "

# erase block size of 256KiB
export MKUBIFS_ARGS_256kbpeb = " -m 4096 -e 248KiB -c 2000 "
export UBINIZE_ARGS_256kbpeb = " -m 4096 -p 256KiB -s 4096 "

# UBIFS for Variscite 1GB NAND flash
# erase block size of 128KiB
#MKUBIFS_ARGS = " -m 2048 -e 124KiB -c 7855 "
#UBINIZE_ARGS = " -m 2048 -p 128KiB -s 2048 "

# erase block size of 512KiB
#MKUBIFS_ARGS = " -m 4096 -e 504KiB -c 2000 "
#UBINIZE_ARGS = " -m 4096 -p 512KiB -s 4096 "

MULTIUBI_BUILD ?= "128kbpeb 256kbpeb"

UBI_VOLNAME  = "rootfs"

IMAGE_FSTYPES = "tar.gz multiubi wic.gz"

# do multiubi last
IMAGE_TYPEDEP_multiubi += "${IMAGE_FSTYPES}"
IMAGE_TYPEDEP_multiubi_remove = "multiubi"

multiubi_mkfs_prepend() {
	# Update PEB size in fw_env.config (u-boot-fw-utils)
	if [ -f ${IMAGE_ROOTFS}${sysconfdir}/fw_env.config ]; then
		# Get PEB from UBINIZE_ARGS
		MTD_ERASESIZE=`echo "$2" | tr ' =' '\n' | awk '/^-p$|^--peb-size$/{getline; print}'`
		# Convert to bytes (decimal)
		MTD_ERASESIZE=`echo $MTD_ERASESIZE | sed 's/MiB/ * 1024 KiB/;s/KiB/ * 1024/' | bc`
		# Convert to hexadecimal
		MTD_ERASESIZE=`printf 0x%x $MTD_ERASESIZE`

		awk -i inplace -v n=4 -v ERASESIZE="${MTD_ERASESIZE}" '/\/dev\/mtd/{$(n)=ERASESIZE}1' ${IMAGE_ROOTFS}${sysconfdir}/fw_env.config
	fi
}
