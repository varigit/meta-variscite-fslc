#!/bin/sh

. /etc/wifi/variscite-wifi.conf
. /etc/wifi/variscite-wifi-common.sh

wifi_suspend()
{
   wifi_down
}

wifi_resume()
{
   wifi_up
   sleep 5
   /etc/bluetooth/variscite-bt
}


#################################################
#              Execution starts here            #
#################################################

if ! som_is_dart_6ul_5g; then
	exit 0
fi

case $1 in

"suspend")
        wifi_suspend
        ;;
"resume")
        wifi_resume
        ;;
esac

exit 0
