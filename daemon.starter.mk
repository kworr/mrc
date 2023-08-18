_service_daemon: .USE
	cd ${DAEMON_$@_CWD} ;\
	daemon -u ${DAEMON_$@_USER} -r -P /var/run/daemon.$@.pid $${CMD} ${DAEMON_$@_FLAGS} ${DAEMON$@_FOREGROUND}

_service_daemon_status: .USE
	echo "Not supported yet."

_service_daemon_exit: .USEBEFORE
	kill -TERM /var/run/daemon.${@:S/_exit//}.pid
