DAEMON_udevd_COMMAND?=/sbin/udevd
DAEMON_udevd_ENABLE?=yes
DAEMON_udevd_FOREGROUND?=-d

udevd: ${_EARLYSERVICE}
