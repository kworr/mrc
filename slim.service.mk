DAEMON_slim_COMMAND?=/usr/local/bin/slim
DAEMON_slim_ENABLE?=no
DAEMON_slim_BACKGROUND?=-d

DAEMON_dbus_DEPS+=slim

slim: ${_SERVICE} dbus
	rm -f /var/run/slim.auth

DAEMON_EXIT: slim_exit
