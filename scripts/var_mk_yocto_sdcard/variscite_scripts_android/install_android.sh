#!/bin/sh
# Installs Android 

. /usr/bin/echos.sh

usage()
{
	echo
	echo "This script installs Andorid on VAR-SOM-MX6"
	echo
	echo " Usage: $0 OPTIONS"
	echo
	echo " OPTIONS:"
	echo " -b <mx6cb|scb|dart>	carrier Board model (MX6CustomBoard/SOLOCustomBoard/DART-MX6) - mandartory parameter."
	echo " -t <cap|res>		Touchscreen model (capacitive/resistive) - mandatory in case of MX6CustomBoard; ignored otherwise."
	echo
}


blue_underlined_bold_echo "*** VAR-MX6 Android eMMC/NAND RECOVERY Version 60 ***"
echo

while getopts :b:t:r: OPTION;
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

STR=""

if [[ $BOARD == "mx6cb" ]] ; then
	STR="MX6CustomBoard"
elif [[ $BOARD == "scb" ]] ; then 
	STR="SOLOCustomBoard"
elif [[ $BOARD == "dart" ]] ; then 
	STR="DART-MX6"
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

node=/dev/${block}


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

CPUS=`cat /proc/cpuinfo | grep processor | wc -l`

if [[ $CPUS == 1 ]] || [[ $CPUS == 2 ]] ; then
	if [[ `dmesg | grep SOM-SOLO | wc -l` == 1 ]] ; then
		if [[ "$BOARD" == "scb" ]] ; then
			BOOTI=som-solo-vsc
		else
			BOOTI=som-solo-$TOUCHSCREEN
		fi
	else
		if [[ $CPUS == 1 ]] || [[ `dmesg | grep i.MX6DL | wc -l` == 1 ]] ; then
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
	if [[ $BOARD == "dart" ]] ; then
		BOOTI=imx6q-var-dart
	elif [[ $BOARD == "scb" ]] ; then
		BOOTI=som-mx6q-vsc
	else
		BOOTI=som-mx6q-$TOUCHSCREEN
	fi
fi

printf "Android eMMC flash "
blue_bold_echo "<$BOOTI>"

/usr/bin/mkmmc_android.sh -f $BOOTI $node

echo
read -p "Android Flashed. Press any key to continue... " -n1
exit 0
