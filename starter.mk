OTHER_TARGETS+=_service_pre

STARTER?=svc

_service_check: .USEBEFORE
	# check whether service is enabled
	if [ -z "$${DAEMON_$@_ENABLE}" -a -z "${FORCE}" ]; then \
		exit 0 ;\
	fi ;\
	for CMD in ${DAEMON_$@_COMMAND}; do \
		if [ -x $${CMD} ]; then \
			export CMD ;\
			break ;\
		fi ;\
	done ;\
	echo $${CMD}

_service_pre: .USEBEFORE
	# kldload modules if any
	echo "MRC:$@> Starting service." ;\
	if [ -n "${DAEMON_$@_MODULES}" ]; then \
		kldload -n ${DAEMON_$@_MODULES}; \
	fi

_service_post_exit: .USE
	echo "MRC:${@:S/_exit//}> stopped."

.for starter_source in ${:!find /etc/mrc -name '*.starter.mk'!:S/\/etc\/mrc\///}
starter:=${starter_source:S/.starter.mk$//}
Starter:=${starter:tu}

OTHER_TARGETS:=${OTHER_TARGETS} _service_${starter} _service_${starter}_exit _service_${starter}_status

_SERVICE_${Starter}:=_service_pre DAEMON _service_${starter} _service_check
_EARLYSERVICE_${Starter}:=_service_pre SERVICE _service_${starter} _service_check
_SERVICE_${Starter}_EXIT:=_service_${starter}_exit _service_post_exit

.if "${STARTER}" == "${starter}"
_SERVICE:=_service_pre DAEMON _service_${starter} _service_check
_EARLYSERVICE:=_service_pre SERVICE _service_${starter} _service_check
_SERVICE_EXIT:=_service_${starter}_exit _service_post_exit
.endif

.export
.include "${starter_source}"
.endfor
