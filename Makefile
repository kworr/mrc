.include "mrc.conf"

.if defined(AUTOBOOT)
SCRIPTS!=ls *.init *.service
.else
SCRIPTS!=ls *.service
.endif

all: ${SERVICE:S/.init//:S/.service//}
