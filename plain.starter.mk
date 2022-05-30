_service_plain: .USE
	chroot -u ${DAEMON_$@_USER:Uroot} -g ${DAEMON_$@_GROUP:Uwheel} / ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS} ${DAEMON_$@_BACKGROUND}

_service_status: .USE
	echo "Plain service status doesn't work right now."

_service_exit: .USEBEFORE
	echo "Plain service exit doesn't work right now."
