SCRIPTS:=${:!find /etc/mrc -name '*.service.mk'!:S/^\/etc\/mrc\///:S/.service.mk$//}

.include "starter.mk"

# Create service targets
.for service in ${SCRIPTS}
.	include "${service}.service.mk"

# Set DAEMON defaults
DAEMON_${service}_CWD?=	/
DAEMON_${service}_ENABLE?=	no
DAEMON_${service}_USER?=	root
DAEMON_${service}_GROUP?=	wheel

.	if !defined(DAEMON_${service}_COMMAND)
.		warning MRC> Service [${service}] defunct: no COMMAND specified
.	else

# Service creation targets
.		if !target(${service})
${service}: ${service}_exit ${_SERVICE} ${service}_after
.		endif
#
# Service part that runs after daemonization, we are just turning them
# to macros and making sure they exist
${service}_after: .USE

# Service status targets
.		if !target(${service}_status)
${service}_status: ${_SERVICE_STATUS}
.		endif

# Service exit targets
.		if !target(${service}_exit)
${service}_exit: ${_SERVICE_EXIT} ${DAEMON_${service}_DEPS:S/$/_exit/}
.		endif

DAEMON_EXIT: ${service}_exit
.	endif
.endfor

.MAIN: ${SCRIPTS} ${TARGETS}

.PHONY: ${SCRIPTS} ${OTHER_TARGETS} ${TARGETS}

.undef SCRIPTS
