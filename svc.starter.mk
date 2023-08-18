_service_svc: .USE
	cd ${DAEMON_$@_CWD} ;\
	svc list $@ | grep -q $@ || \
		svc -u ${DAEMON_$@_USER} -g ${DAEMON_$@_GROUP} ${DAEMON_$@_RESTART:D-r} ${DAEMON_$@_RESTART} init $@ ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS} ${DAEMON_$@_FOREGROUND}

_service_svc_status: .USE
	svc status ${@:S/_status//}

_service_svc_exit: .USEBEFORE
	svc list ${@:S/_exit//} | grep -q ${@:S/_exit//} || true && \
		svc -s exit ${@:S/_exit//}
