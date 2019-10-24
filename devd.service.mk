DAEMON_devd_COMMAND?=/sbin/devd
DAEMON_devd_ENABLE?=yes
DAEMON_devd_FOREGROUND?=-dq

devd: _earlyservice
	test -n "$${DAEMON_$@_ENABLE}" || sysctl hw.bus.devctl_disable=1
