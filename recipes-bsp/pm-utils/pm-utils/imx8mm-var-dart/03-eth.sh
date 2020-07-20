#!/bin/sh

case $1 in

"suspend")
        ifconfig eth0 down
        ;;
"resume")
        ifconfig eth0 up
        ;;
esac

