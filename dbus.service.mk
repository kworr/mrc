DAEMON_dbus_COMMAND?=/usr/local/bin/dbus-daemon
DAEMON_dbus_ENABLE?=no
DAEMON_dbus_FLAGS?=--system
DAEMON_dbus_BACKGROUND?=--fork
DAEMON_dbus_FOREGROUND?=--nofork

dbus: ${_SERVICE}
	/usr/local/bin/dbus-uuidgen --ensure
	mkdir -p /var/run/dbus

dbus_exit: ${_SERVICE_EXIT} slim_exit
