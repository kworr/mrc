LOCAL_TARGETS:=_daemon_svc _service_svc
OTHER_TARGETS+=${LOCAL_TARGETS}
.if ${DAEMONIZER} == "svc"
LOCAL_TARGETS:=${LOCAL_TARGETS} ${LOCAL_TARGETS:S/_svc//}
.endif

.for target in ${LOCAL_TARGETS}
${target}: ${target:M_daemon:DDAEMON} .USE
#.export DAEMON_$@_ENABLE
	env | grep $@
	test -z "$${DAEMON_$@_ENABLE}" || { \
	  test -n "${DAEMON_$@_MODULES}" && kldload -n ${DAEMON_$@_MODULES} || true; \
	  svc -u ${DAEMON_$@_USER:Uroot} -g ${DAEMON_$@_GROUP:Uwheel} init $@ ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS}; \
	}
.endfor

#_service: .USE
#.export DAEMON_$@_ENABLE
#	env | grep $@
#	test -z "$${DAEMON_$@_ENABLE}" || { \
#	  test -n "${DAEMON_$@_MODULES}" && kldload -n ${DAEMON_$@_MODULES} || true; \
#	  svc -u ${DAEMON_$@_USER:Uroot} -g ${DAEMON_$@_GROUP:Uwheel} init $@ ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS}; \
#	}

.undef LOCAL_TARGETS
