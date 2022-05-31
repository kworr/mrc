DAEMON_dbus_COMMAND?=/usr/local/bin/dbus-daemon
DAEMON_dbus_ENABLE?=no
DAEMON_dbus_FLAGS?=--system --syslog
DAEMON_dbus_BACKGROUND?=--fork
DAEMON_dbus_FOREGROUND?=--nofork --nopidfile

dbus: ${_SERVICE}
	/usr/local/bin/dbus-uuidgen --ensure
	mkdir -p /var/run/dbus
