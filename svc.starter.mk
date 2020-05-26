LOCAL_TARGETS:=_service_svc _earlyservice_svc
STATUS_TARGETS:=_status_svc
RESTART_TARGETS:=_restart_svc
OTHER_TARGETS+=${LOCAL_TARGETS} ${STATUS_TARGETS} ${RESTART_TARGETS}
.if ${STARTER} == "svc"
LOCAL_TARGETS+=_service _earlyservice
STATUS_TARGETS+=_status
RESTART_TARGETS+=_restart
.endif

.for target in ${LOCAL_TARGETS}
${target}: ${target:C/_service.*/DAEMON/:C/_earlyservice/SERVICE/} .USE
	test -z "$${DAEMON_$@_ENABLE}" || { \
	  echo "MRC:$@> Starting service."; \
	  test -n "${DAEMON_$@_MODULES}" && kldload -n ${DAEMON_$@_MODULES} || true; \
	  svc -u ${DAEMON_$@_USER:Uroot} -g ${DAEMON_$@_GROUP:Uwheel} ${DAEMON_$@_RESTART:D-r} ${DAEMON_$@_RESTART} init $@ ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS} ${DAEMON_$@_FOREGROUND}; \
	}
.endfor

.for target in ${RESTART_TARGETS}
${target}: .USE
	svc restart $@
.endfor

.for target in ${STATUS_TARGETS}
${target}: .USE
	svc status $@
.endfor

.undef LOCAL_TARGETS
.undef RESTART_TARGETS
.undef STATUS_TARGETS
