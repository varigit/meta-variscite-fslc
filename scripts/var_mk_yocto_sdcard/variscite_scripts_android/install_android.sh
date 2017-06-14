#!/bin/sh
# Installs Android
set -e

. /usr/bin/echos.sh

usage()
{
	echo
	echo "This script installs Andorid on the SOM's internal storage device/s"
	echo
	echo " Usage: $0 OPTIONS"
	echo
	echo " OPTIONS:"
	echo " -b <mx6cb|scb|dart>	carrier Board model (MX6CustomBoard/SOLOCustomBoard/DART-MX6) - mandartory parameter."
	echo " -t <cap|res>		Touchscreen model (capacitive/resistive) - mandatory in case of MX6CustomBoard; ignored otherwise."
	echo
}

blue_underlined_bold_echo "*** Variscite MX6 Android eMMC/NAND Recovery ***"
echo

while getopts :b:t: OPTION;
do
	case $OPTION in
	b)
		BOARD=$OPTARG
		;;
	t)
		TOUCHSCREEN=$OPTARG
		;;
	*)
		usage
		exit 1
		;;
	esac
done

is_dart=flase
STR=""

if [[ $BOARD == "mx6cb" ]] ; then
	STR="MX6CustomBoard"
elif [[ $BOARD == "scb" ]] ; then
	STR="SOLOCustomBoard"
elif [[ $BOARD == "dart" ]] ; then
	STR="DART-MX6"
	is_dart=true
else
	usage
	exit 1
fi

printf "Carrier board: "
blue_bold_echo $STR

if [[ $BOARD == "dart" ]] ; then
	block=mmcblk2
else
	block=mmcblk0
fi

if [[ $BOARD == "mx6cb" ]] ; then
	if [[ $TOUCHSCREEN == "cap" ]] ; then
		STR="Capacitive"
		TOUCHSCREEN=c
	elif [[ $TOUCHSCREEN == "res" ]] ; then
		STR="Resistive"
		TOUCHSCREEN=r
	else
		usage
		exit 1
	fi
	printf "Touchscreen model: "
	blue_bold_echo $STR
fi

CPUS=`cat /proc/cpuinfo | grep -c processor`

if [[ $CPUS == 1 ]] || [[ $CPUS == 2 ]] ; then
	if [[ `dmesg | grep -c SOM-SOLO` == 1 ]] ; then
		if [[ "$BOARD" == "scb" ]] ; then
			BOOTI=som-solo-vsc
		else
			BOOTI=som-solo-$TOUCHSCREEN
		fi
	else
		if [[ $CPUS == 1 ]] || [[ `dmesg | grep -c i.MX6DL` == 1 ]] ; then
			# iMX6 Solo/DualLite
			BOOTI=som-mx6dl-$TOUCHSCREEN
		else
			# iMX6 Dual
			CPUS=4
		fi
	fi
fi

#iMX6 Dual/Quad
if [[ $CPUS == 4 ]] ; then
	if [[ `cat /sys/devices/soc0/soc_id` == "i.MX6QP" ]] ; then
		QUADTYPE="mx6qp"
	else
		QUADTYPE="mx6q"
	fi
	if [[ $BOARD == "dart" ]] ; then
		BOOTI=imx6q-var-dart
	elif [[ $BOARD == "scb" ]] ; then
		BOOTI=som-$QUADTYPE-vsc
	else
		BOOTI=som-$QUADTYPE-$TOUCHSCREEN
	fi
fi

printf "Android eMMC flash "
blue_bold_echo "<$BOOTI>"

/usr/bin/install_android_emmc.sh -f $BOOTI $block $is_dart

echo
blue_bold_echo "Android installed successfully"
exit 0
