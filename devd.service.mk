DAEMON_devd_COMMAND?=/sbin/devd
DAEMON_devd_ENABLE?=yes
DAEMON_devd_FOREGROUND?=-dq

devd: ${_EARLYSERVICE}
	sysctl hw.bus.devctl_disable=1
