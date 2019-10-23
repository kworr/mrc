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

#.MAKE.JOBS?=2
.SILENT:

install:
	install rc /etc/rc

SCRIPTS=${:!find /etc/mrc -name '*.service.mk'!:S/\/etc\/mrc\///}

.if defined(AUTOBOOT)
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
.endif

test:
	echo Empty target.

TARGETS:=${SCRIPTS:S/.init.mk//:S/.service.mk//}

.for file in ${SCRIPTS}
#.info ${file}
.include "${file}"
.endfor

.include "init.mk"

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
