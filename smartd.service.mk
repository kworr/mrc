DAEMON_smartd_COMMAND?=/usr/local/sbin/smartd
DAEMON_smartd_ENABLE?=no
DAEMON_smartd_FLAGS?=-c /usr/local/etc/smartd.conf
DAEMON_smartd_FOREGROUND?=-n

smartd: ${_SERVICE}
	if [ ! -f /usr/local/etc/smartd.conf ]; then \
		echo "MRC:$@> smartd requires config file to start."; \
		exit 1; \
	fi
