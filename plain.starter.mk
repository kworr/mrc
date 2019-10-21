LOCAL_TARGETS:=_service_plain _earlyservice_plain
OTHER_TARGETS+=${LOCAL_TARGETS}
.if ${STARTER} == "plain"
LOCAL_TARGETS+=_service _earlyservice
.endif

.for target in ${LOCAL_TARGETS}
${target}: ${target:C/_service.*/DAEMON/:C/_earlyservice.*/SERVICE/} .USE
	test -z "$${DAEMON_$@_ENABLE}" || { \
	  test -n "${DAEMON_$@_MODULES}" && kldload -n ${DAEMON_$@_MODULES} || true; \
	  chroot -u ${DAEMON_$@_USER:Uroot} -g ${DAEMON_$@_GROUP:Uwheel} / ${DAEMON_$@_COMMAND} ${DAEMON_$@_FLAGS}; \
	}
.endfor

.undef LOCAL_TARGETS
