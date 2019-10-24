DAEMON_smartd_COMMAND?=/usr/local/sbin/smartd
DAEMON_smartd_ENABLE?=no
DAEMON_smartd_FLAGS?=-c /usr/local/etc/smartd.conf
DAEMON_smartd_FOREGROUND?=-n

smartd: _service
	test -z "$${DAEMON_$@_ENABLE}" || \
	test -f /usr/local/etc/smartd.conf || { \
	  echo "MRC:$@> smartd requires config file to start." ; \
	  false; \
	}
