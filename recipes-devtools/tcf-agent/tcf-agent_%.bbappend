# there is a bug with killproc function that waits tool long and delays the reboot process, replace with alternative	
do_install_prepend() {
	sed -i 's/.*killproc.*/            start-stop-daemon -K --exec $DAEMON_PATH --signal=HUP/' ${WORKDIR}/tcf-agent.init	 
}

