DAEMON_moused_COMMAND?=/usr/sbin/moused
DAEMON_moused_ENABLE?=yes
DAEMON_moused_FLAGS?=-p ${MOUSED_PORT} -t ${MOUSED_TYPE}
DAEMON_moused_FOREGROUND?=-f

moused: ${_SERVICE}
	for ttyv in /dev/ttyv*; do vidcontrol < $$ttyv -m on; done
