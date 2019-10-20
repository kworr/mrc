.include "/etc/mrc.conf"
.export

DAEMONIZER?=svc.daemon

#.MAKE.JOBS?=2
.SILENT:

.include "${DAEMONIZER}"

.if defined(AUTOBOOT)
SCRIPTS=${:!find /etc/mrc -name '*.init' -o -name '*.service'!:S/\/etc\/mrc\///}

.ERROR:
	: ERROR: ABORTING BOOT (sending SIGTERM to parent)!
	: target ${.ERROR_TARGET} failed to execute:
	: ${.ERROR_CMD}
	kill 1
.else
SCRIPTS=${:!find /etc/mrc -name '*.service'!:S/\/etc\/mrc\///}

DAEMON:
.endif

TARGETS:=${SCRIPTS:S/.init//:S/.service//}

.MAIN: ${TARGETS}

.PHONY: ${TARGETS} _daemon _service

.for file in ${SCRIPTS}
.include "${file}"
.endfor
