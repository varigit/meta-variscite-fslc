#!/bin/sh

westonapp_start()
{
    # check XDG_RUNTIME_DIR
    if test -z "$XDG_RUNTIME_DIR"; then
        export XDG_RUNTIME_DIR=/run/user/`id -u`
        if ! test -d "$XDG_RUNTIME_DIR"; then
            mkdir --parents $XDG_RUNTIME_DIR
            chmod 0700 $XDG_RUNTIME_DIR
        fi
    fi

    # wait for wayland to start
    while [ ! -e $XDG_RUNTIME_DIR/wayland-0 ]
    do
        sleep 0.1
    done

    # start the application
    kill -9 $(pidof weston-app) 2>/dev/null || true
    /usr/bin/weston-app &
}

westonapp_stop()
{
    kill -9 $(pidof weston-app) 2>/dev/null || true
}

###########################
#  Execution starts here  #
###########################
case $1 in

start)
	westonapp_start
	;;
stop)
	westonapp_stop
	;;
esac

exit 0
