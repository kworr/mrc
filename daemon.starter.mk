_service_daemon: .USE
	daemon -c -u ${DAEMON_$@_USER:Uroot} -r -P /var/run/daemon.$@.pid ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS} ${DAEMON$@_FOREGROUND}

_service_daemon_status: .USE
	echo "Not supported yet."

_service_daemon_exit: .USEBEFORE
	kill -TERM /var/run/daemon.${@:S/_exit//}.pid
