.include "defaults.mk"
.include "/etc/mrc.mk"
.export

OTHER_TARGETS:=_service _earlyservice
STARTER?=svc

.for starter in ${:!find /etc/mrc -name '*.starter.mk'!:S/\/etc\/mrc\///}
.include "${starter}"
.endfor

.if !target(_service) || !target(_earlyservice)
.error No service handler defined.
.endif

.SILENT:

install:
	install rc /etc/rc

SCRIPTS=${:!find /etc/mrc -name '*.service.mk'!:S/\/etc\/mrc\///}
TARGETS:=${SCRIPTS:S/.service.mk//}

.if defined(AUTOBOOT)
.include "init.mk"

.ERROR:
	: ERROR: ABORTING BOOT (sending SIGTERM to parent)!
	: target ${.ERROR_TARGET} failed to execute:
	: ${.ERROR_CMD}
	kill 1
.else
DAEMON: NETWORK SERVERS
LOGIN: DAEMON
NETWORK:
SERVERS:
SERVICE:

mount:
root:
netif:
newsyslog:
.endif

test:
	echo Empty target.

.for file in ${SCRIPTS}
#.info ${file}
.include "${file}"
.if !target(${file:S/.service.mk//})
${file:S/.service.mk//}: _service
.endif
.if !target(${file:S/.service.mk/_status/})
${file:S/.service.mk/_status/}: _status
.endif
.if !target(${file:S/.service.mk/_restart/})
${file:S/.service.mk/_restart/}: _restart
.endif
.endfor

.MAIN: ${TARGETS}

.PHONY: ${TARGETS} ${OTHER_TARGETS}

.undef TARGETS OTHER_TARGETS SCRIPTS

ENABLED=${:!env!:C/=.*//:M*_ENABLE}

.for var in ${ENABLED}
.if !empty(${var}:tl:Mno)
#.info ${var}
.undef ${var}
.endif
.endfor

.undef ENABLED
.unexport-env
.export
#.info ${:!env!}
