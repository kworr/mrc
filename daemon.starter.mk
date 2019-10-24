LOCAL_TARGETS:=_service_daemon _earlyservice_daemon
OTHER_TARGETS+=${LOCAL_TARGETS}
.if ${STARTER} == "daemon"
LOCAL_TARGETS+=_service _earlyservice
.endif

.for target in ${LOCAL_TARGETS}
${target}: ${target:C/_service.*/DAEMON/:C/_earlyservice.*/SERVICE/} .USE
	test -z "$${DAEMON_$@_ENABLE}" || { \
	  echo "MRC:$@> Starting service."; \
	  test -n "${DAEMON_$@_MODULES}" && kldload -n ${DAEMON_$@_MODULES} || true; \
	  daemon -c -u ${DAEMON_$@_USER:Uroot} -r -P /var/run/daemon.$@.pid ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS} ${DAEMON$@_FOREGROUND}; \
	}
.endfor

.undef LOCAL_TARGETS
