.include "defaults.mk"
.include "order.mk"
.include "/etc/mrc.mk"
.export

.MAKE.JOBS?=1
.if !empty(.MAKE.MODE:Mcompat)
.error "ERROR: MRC doesn't support "compat" mode."
.endif

OTHER_TARGETS:=

.include "starter.mk"

.SILENT:

install:
	install rc /etc/rc
	install rc.shutdown /etc/rc.shutdown

SCRIPTS:=${:!find /etc/mrc -name '*.service.mk'!:S/^\/etc\/mrc\///:S/.service.mk$//}

.if defined(AUTOBOOT)
.include "init.mk"

.ERROR:
	: ERROR: ABORTING BOOT (sending SIGTERM to parent)!
	: target ${.ERROR_TARGET} failed to execute:
	: ${.ERROR_CMD}
	kill 1
.endif

test:
	echo Empty target.

# Create service targets
.for service in ${SCRIPTS}
.	include "${service}.service.mk"

# Service creation targets
.	if !target(${service})
${service}: ${SERVICE_EXIT} ${_SERVICE}
.	endif

# Service status targets
.	if !target(${service}_status)
${service}_status: ${_SERVICE_STATUS}
.	endif

# Service exit targets
.	if !target(${service}_exit)
${service}_exit: ${_SERVICE_EXIT} ${DAEMON_${service}_DEPS:S/$/_exit/}
.	endif

DAEMON_EXIT: ${service}_exit
.endfor

.MAIN: ${SCRIPTS} ${TARGETS}

.PHONY: ${SCRIPTS} ${OTHER_TARGETS} ${TARGETS}
.undef OTHER_TARGETS SCRIPTS TARGETS

ENABLED:=${:!env!:C/=.*//:M*_ENABLE}

.for var in ${ENABLED}
.	if !empty(${var}:tl:Mno)
#.info ${var}
.		undef ${var}
.	endif
.endfor

.undef ENABLED
.unexport-env
.export
#.info ${:!env!}
