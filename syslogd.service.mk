DAEMON_syslogd_COMMAND?=/usr/sbin/syslogd
DAEMON_syslogd_ENABLE?=yes
DAEMON_syslogd_FLAGS?=-ss8cc

syslogd: _earlyservice