LOCAL_TARGETS:=_service_svc _earlyservice_svc
OTHER_TARGETS+=_service_svc _earlyservice_svc
.if ${STARTER} == "svc"
LOCAL_TARGETS+=_service _earlyservice
.endif

.for target in ${LOCAL_TARGETS}
${target}: ${target:C/_service.*/DAEMON/:C/_earlyservice/SERVICE/} .USE
	test -z "$${DAEMON_$@_ENABLE}" || { \
	  echo "MRC:$@> Starting service."; \
	  test -n "${DAEMON_$@_MODULES}" && kldload -n ${DAEMON_$@_MODULES} || true; \
	  svc -u ${DAEMON_$@_USER:Uroot} -g ${DAEMON_$@_GROUP:Uwheel} init $@ ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS}; \
	}
.endfor

.undef LOCAL_TARGETS
