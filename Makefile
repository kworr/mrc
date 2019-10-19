.include "/etc/mrc.conf"

DAEMONIZER?=svc.daemon

.include "${DAEMONIZER}"

.if defined(AUTOBOOT)
SCRIPTS!=ls *.init *.service
.else
SCRIPTS!=ls *.service
.endif

all: ${SERVICE:S/.init//:S/.service//}

.for file in ${SCRIPTS}
.include "${file}"
.endfor
