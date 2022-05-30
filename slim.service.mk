DAEMON_slim_COMMAND?=/usr/local/bin/slim
DAEMON_slim_ENABLE?=no
DAEMON_slim_BACKGROUND?=-d

slim: ${_SERVICE} dbus
	rm -f /var/run/slim.auth

DAEMON_EXIT: slim_exit
