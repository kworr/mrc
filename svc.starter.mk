_service_svc: .USE
	cd ${DAEMON_$@_CWD} ;\
	svc list $@ | grep -q $@ || \
		svc -u ${DAEMON_$@_USER} -g ${DAEMON_$@_GROUP} ${DAEMON_$@_RESTART:D-r} ${DAEMON_$@_RESTART} init $@ $${CMD} ${DAEMON_$@_FLAGS} ${DAEMON_$@_FOREGROUND} > /dev/null

_service_svc_status: .USE
	svc status ${@:S/_status//}

_service_svc_exit: .USEBEFORE
	#svc list ${@:S/_exit//} | grep -q ${@:S/_exit//} || true &&
	lockf -kst 0 /var/run/service.${@:S/_exit//}.pid svc -t 0 kill ${@:S/_exit//} || \
		svc -s exit ${@:S/_exit//} > /dev/null
