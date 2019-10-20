.include "/etc/mrc.conf"

DAEMONIZER?=svc.daemon

.MAKE.JOBS?=2
.SILENT:

.include "${DAEMONIZER}"

.if defined(AUTOBOOT)
SCRIPTS!=ls *.init *.service
.else
SCRIPTS!=ls *.service

DAEMON:
.endif

.MAIN: ${SCRIPTS:S/.init//:S/.service//}

.PHONY: ${SCRIPTS:S/.init//:S/.service//} _daemon _service

.for file in ${SCRIPTS}
.include "${file}"
.endfor
