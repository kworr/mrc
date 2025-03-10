OTHER_TARGETS+=_service_pre

STARTER?=svc

_service_check: .USEBEFORE
	# check whether service is enabled
	if [ -z "$${DAEMON_$@_ENABLE}" -a -z "${FORCE}" ]; then \
		exit 0 ;\
	fi
	# check for first present executable
	for CHECK_CMD in ${DAEMON_$@_COMMAND}; do \
		if [ -x $${CHECK_CMD} ]; then \
			export CMD="$${CHECK_CMD}" ;\
			break ;\
		fi ;\
	done
	# bail out if binary not found
	if [ -z $${CMD} ]; then \
		echo "MRC:$@> Executable not found." ;\
		exit 0 ;\
	fi

_service_check_start: .USEBEFORE
	# check for rtprio/idprio
	if [ -n "$${DAEMON_$@_IDPRIO}" ]; then \
		export CMD="/usr/sbin/idprio $${DAEMON_$@_IDPRIO} $${CMD}" ;\
	elif [ -n "$${DAEMON_$@_RTPRIO}" ]; then \
		export CMD="/usr/sbin/rtprio $${DAEMON_$@_RTPRIO} $${CMD}" ;\
	fi

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

# here we are inheriting pieces of different targets into one single target, so
# everything is appended in the order, but gets organized a little bit
# differently, all targets with .USEBEFORE are added before current target
# script, so after "_service_pre _service_check" we got that order inverted

_SERVICE_${Starter}:=_service_pre DAEMON _service_${starter} _service_check_start _service_check
_EARLYSERVICE_${Starter}:=_service_pre SERVICE _service_${starter} _service_check_start _service_check
_SERVICE_${Starter}_EXIT:=_service_${starter}_exit _service_post_exit _service_check

.	if "${STARTER}" == "${starter}"
_SERVICE:=${_SERVICE_${Starter}}
_EARLYSERVICE:=${_EARLYSERVICE_${Starter}}
_SERVICE_EXIT:=${_SERVICE_${Starter}_EXIT}
.	endif

.	export-all
.	include "${starter_source}"
.endfor
