.include "defaults.mk"
.include "order.mk"
.include "/etc/mrc.mk"
.export

.MAKE.JOBS?=	${NCPU}
.if !empty(.MAKE.MODE:Mcompat)
.error "ERROR: MRC doesn't support "compat" mode."
.endif

OTHER_TARGETS:=

.SILENT:

install:
	install rc /etc/rc
	install rc.shutdown /etc/rc.shutdown

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

.include "service.mk"

.undef OTHER_TARGETS TARGETS

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
