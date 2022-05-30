_service_svc: .USE
	svc list $@ | grep -q $@ || \
	svc -u ${DAEMON_$@_USER:Uroot} -g ${DAEMON_$@_GROUP:Uwheel} ${DAEMON_$@_RESTART:D-r} ${DAEMON_$@_RESTART} init $@ ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS} ${DAEMON_$@_FOREGROUND}

_service_svc_status: .USE
	svc status $@

_service_svc_exit: .USEBEFORE
	svc exit $@
