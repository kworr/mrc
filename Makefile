.include "/etc/mrc.conf"
.export

OTHER_TARGETS:=_daemon _service
DAEMONIZER?=svc

.for daemonizer in ${:!find /etc/mrc -name '*.daemon.mk'!:S/\/etc\/mrc\///}
.include "${daemonizer}"
.endfor

.if !target(_daemon) || !target(_service)
.error No daemonizer defined.
.endif

#.MAKE.JOBS?=2
#.SILENT:

.if defined(AUTOBOOT)
SCRIPTS=${:!find /etc/mrc -name '*.init' -o -name '*.service'!:S/\/etc\/mrc\///}

.ERROR:
	: ERROR: ABORTING BOOT (sending SIGTERM to parent)!
	: target ${.ERROR_TARGET} failed to execute:
	: ${.ERROR_CMD}
	kill 1
.else
SCRIPTS=${:!find /etc/mrc -name '*.service'!:S/\/etc\/mrc\///}

DAEMON: NETWORK SERVERS

LOGIN: DAEMON

NETWORK:

SERVERS:

mountlate: mount cleanvar

mount:

cleanvar: mount

nfsclient: NETWORK
.endif

TARGETS:=${SCRIPTS:S/.init//:S/.service//}

.MAIN: ${TARGETS}

.PHONY: ${TARGETS} ${OTHER_TARGETS}

.undef TARGETS OTHER_TARGETS

.for file in ${SCRIPTS}
.info ${file}
.include "${file}"
.endfor

.undef SCRIPTS

ENABLED=${:!env!:C/=.*//:M*_ENABLE}

.for var in ${ENABLED}
.if !empty(${var}:tl:Mno)
#.info ${var}
.undef ${var}
.unexport ${var}
.endif
.endfor

.undef ENABLED
