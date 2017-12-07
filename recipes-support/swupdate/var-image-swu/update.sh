#!/bin/sh

if [ $# -lt 1 ]; then
	exit 0;
fi

function get_current_root_device
{
	for i in `cat /proc/cmdline`; do
		if [ ${i:0:5} = "root=" ]; then
			CURRENT_ROOT="${i:5}"
		fi
	done
}

function get_update_part
{
	CURRENT_PART="${CURRENT_ROOT: -1}"
	if [ $CURRENT_PART = "1" ]; then
		UPDATE_PART="2";
	else
		UPDATE_PART="1";
	fi
}

function get_update_device
{
	UPDATE_ROOT=${CURRENT_ROOT%?}${UPDATE_PART}
}

function format_update_device
{
	umount $UPDATE_ROOT
	mkfs.ext4 $UPDATE_ROOT -F -L rootfs${UPDATE_PART}
}

if [ $1 == "preinst" ]; then
	# get the current root device
	get_current_root_device

	# get the device to be updated
	get_update_part
	get_update_device

	# format the device to be updated
	format_update_device

	# create a symlink for the update process
	ln -sf $UPDATE_ROOT /dev/update
fi

if [ $1 == "postinst" ]; then
	get_current_root_device

	if [ ! -d "/sys/kernel/debug/gpmi-nand" ]; then
		# Adjust u-boot-fw-utils for eMMC on the installed rootfs
		mount -t ext4 /dev/update /tmp/datadst
		rm /tmp/datadst/sbin/fw_printenv-nand
		mv /tmp/datadst/sbin/fw_printenv-mmc /tmp/datadst/sbin/fw_printenv
		sed -i "/mtd/ s/^#*/#/" /tmp/datadst/etc/fw_env.config
		CURRENT_BLK_DEV=${CURRENT_ROOT%p?}
		sed -i "s/#*\/dev\/mmcblk./${CURRENT_BLK_DEV//\//\\/}/" /tmp/datadst/etc/fw_env.config
		umount /dev/update
	fi

	get_update_part

	fw_setenv mmcbootpart $UPDATE_PART
	fw_setenv mmcrootpart $UPDATE_PART
fi
