DAEMON_arpwatch_COMMAND?=/usr/local/sbin/arpwatch
DAEMON_arpwatch_CWD?=/usr/local/arpwatch
DAEMON_arpwatch_FOREGROUND?=-F

arpwatch: ${_SERVICE}
	DATFILE="${DAEMON_arpwatch_CWD}/arp.dat" ;\
	if [ ! -e $${DATFILE} ]; then \
		if [ -e $${DATFILE}- ]; then \
			cp $${DATFILE}- $${DATFILE} ;\
		else \
			touch $${DATFILE} ;\
		fi ;\
	fi
