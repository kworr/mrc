DAEMON_watchdogd_COMMAND?=/usr/sbin/watchdogd
DAEMON_watchdogd_ENABLE?=no
DAEMON_watchdogd_FLAGS?=-d

.if empty(:!sysctl -qn debug.watchdog || exit 0!)
DAEMON_watchdogd_ENABLE=no
.endif

watchdogd: _earlyservice