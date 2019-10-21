DAEMON_dbus_COMMAND?=/usr/local/bin/dbus-daemon
DAEMON_dbus_ENABLE?=no
DAEMON_dbus_FLAGS?=--system

dbus: _service
	test -z "$${DAEMON_$@_ENABLE}" || { \
	  /usr/local/bin/dbus-uuidgen --ensure; \
	  mkdir -p /var/run/dbus; \
	}
