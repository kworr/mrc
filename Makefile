.include "/etc/mrc.conf"
.export

DAEMONIZER?=svc.daemon

#.MAKE.JOBS?=2
.SILENT:

.include "${DAEMONIZER}"

.if defined(AUTOBOOT)
SCRIPTS=${:!find /etc/mrc -name '*.init' -o -name '*.service'!:S/\/etc\/mrc\///}
.else
SCRIPTS=${:!find /etc/mrc -name '*.service'!:S/\/etc\/mrc\///}

DAEMON:
.endif

.MAIN: ${SCRIPTS:S/.init//:S/.service//}

.PHONY: ${SCRIPTS:S/.init//:S/.service//} _daemon _service

.for file in ${SCRIPTS}
.include "${file}"
.endfor
