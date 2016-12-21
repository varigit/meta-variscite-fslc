#!/bin/sh -e

#### Script version ####
SCRIPT_NAME=${0##*/}
readonly SCRIPT_VERSION="0.1"

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=`readlink -e "$0"`
readonly ABSOLUTE_DIRECTORY=`dirname ${ABSOLUTE_FILENAME}`
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}

readonly HCI_DEV='hci0'

## tools ##
readonly HCITOOL=hcitool
readonly HCICONFIG=hciconfig
readonly BLUETOOTHCTL=bluetoothctl

## global variables ##
OPT_DISABLE=0
OPT_TRUST_BDADDR=""

## functions ##
function up() {
	# enable
	${HCICONFIG} ${HCI_DEV} up
	sleep 1

	# make it discoverable
	${HCICONFIG} ${HCI_DEV} piscan
	sleep 2

	# tuning bluetooth config
	## set name
	${HCICONFIG} ${HCI_DEV} name "VAR-A2DP"
	sleep 1

	## set class (a2dp)
	${HCICONFIG} ${HCI_DEV} class 0x200414
	sleep 1

	# force starting pulseaudio server
	pactl list cards > /dev/null
}

function down() {
	${HCICONFIG} ${HCI_DEV} noscan
	sleep 2

	${HCICONFIG} ${HCI_DEV} class 0x0
}

help() {
	echo " Usage: ${SCRIPT_NAME} <options> device_node"
	echo
	echo " options:"
	echo " -h	Display this help message"
	echo " -d	Disable a2dp bluetooth server"
	echo " -t <bd_addr>	trust client device (example -t C8:14:79:27:F1:82)"
	echo
}

SHORTOPTS="dht:"
LONGOPTS="disable,help,trust:"

ARGS=$(getopt -s bash --options $SHORTOPTS  \
  --longoptions $LONGOPTS --name $SCRIPT_NAME -- "$@" )

eval set -- "$ARGS"

while true; do
	case $1 in
		-d|--disable ) # disable bluetooth snd server
		    OPT_DISABLE="1";
		    ;;
		-h|--help ) # get help
		    usage
		    exit 0;
		    ;;
		-t|--trust )
		    shift;
		    OPT_TRUST_BDADDR=$1;
			;;
		-- )
		    shift
		    break
		    ;;
		* )
		    shift
		    break
		    ;;
	esac
	shift
done

## main ##
### trust connected device ###
[ "${OPT_TRUST_BDADDR}" = "" ] || {
${BLUETOOTHCTL} << EOF
trust ${OPT_TRUST_BDADDR}
EOF
	exit $?;
};

### disable server ###
[ ${OPT_DISABLE} = "1" ] && {
	down
	exit $?;
};

### enable server ###
up
exit $?
