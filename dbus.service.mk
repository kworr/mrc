DAEMON_dbus_COMMAND?=/usr/local/bin/dbus-daemon
DAEMON_dbus_FLAGS?=--system --syslog
DAEMON_dbus_BACKGROUND?=--fork
DAEMON_dbus_FOREGROUND?=--nofork --nopidfile

dbus: ${_SERVICE}
	mkdir -p /var/run/dbus /var/lib/dbus
	/usr/local/bin/dbus-uuidgen --ensure
