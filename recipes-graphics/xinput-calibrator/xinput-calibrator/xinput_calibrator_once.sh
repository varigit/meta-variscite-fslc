#!/bin/sh
# script to make the changes permanent (xinput is called with every Xorg start)
#
# can be used from Xsession.d
# script needs tee and sed (busybox variants are enough)
#
# original script: Martin Jansa <Martin.Jansa@gmail.com>, 2010-01-31
# updated by Tias Guns <tias@ulyssis.org>, 2010-02-15
# updated by Koen Kooi <koen@dominion.thruhere.net>, 2012-02-28
# updated by Ron Donio <ron.d@variscite.com>, 2015-1-9 Updated for Variscite.

PATH="/usr/bin:$PATH"

BINARY="xinput_calibrator"
SYS_CALFILE="/etc/pointercal.xinput"
LOGFILE="/var/log/xinput_calibrator.pointercal.log"
CALFILES="$SYS_CALFILE"



. $CALFILE

exit 0

