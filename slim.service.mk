DAEMON_slim_COMMAND?=/usr/local/bin/slim
DAEMON_slim_ENABLE?=no

slim: _service dbus
	rm -f /var/run/slim.auth
