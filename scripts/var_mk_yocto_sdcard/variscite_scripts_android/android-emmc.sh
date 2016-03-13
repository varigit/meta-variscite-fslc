#!/bin/sh
#
# Variscite Flash NAND for Android 
#

VSC=$(i2cdump  -y -r 0-0  1 0x51 b | tail -n 1)
VSC=${VSC:4:2}

(dmesg | grep " CTW6120: revid 0 touchscreen")  # Check ifctw6120-tsc
if [ $? -eq 0 ]      # check exit code; if 0 No BT else BT
then
	echo "Set for Capacitive Display"
	TOUCH=c
else
	echo "Set for Resistive Display"
	TOUCH=r
fi


#

if [ `cat /proc/cpuinfo |grep processor | wc -l` = 1 ] ; then
	if [ `dmesg |grep SOM-SOLO | wc -l` = 1 ] ; then
		if [[ "$VSC" == "ff" ]]
		then
			BOOTI=som-solo-vsc
		else
			BOOTI=som-solo-$TOUCH
		fi
	else
	        BOOTI=som-mx6dl-$TOUCH
	fi
fi

if [ `cat /proc/cpuinfo |grep processor | wc -l` = 2 ] ; then

	if [ `dmesg |grep SOM-SOLO | wc -l` = 1 ] ; then
		if [[ "$VSC" == "ff" ]]
		then
			BOOTI=som-solo-vsc
		else
			BOOTI=som-solo-$TOUCH
		fi
	else
		if [ `dmesg |grep i.MX6DL | wc -l` = 1 ] ; then
			BOOTI=som-mx6dl-$TOUCH
		else
			BOOTI=som-mx6q-$TOUCH
		fi
	fi
fi

if [ `cat /proc/cpuinfo |grep processor | wc -l` = 4 ] ; then
	if [ `dmesg |grep VAR-DART | wc -l` = 1 ] ; then
		BOOTI=imx6q-var-dart
	else
		if [[ "$VSC" == "ff" ]]; then
			BOOTI=som-mx6q-vsc
		else
			BOOTI=som-mx6q-$TOUCH
		fi
	fi
fi

echo "Android eMMC flash <$BOOTI>"
if [ `dmesg |grep VAR-DART | wc -l` = 1 ] ; then
	/bin/sh /sbin/mkmmc_android.sh -f $BOOTI /dev/mmcblk2
else
	/bin/sh /sbin/mkmmc_android.sh -f $BOOTI /dev/mmcblk1
fi

read -p "Android Flashed. Press any key to continue... " -n1 -s
#
exit 0
