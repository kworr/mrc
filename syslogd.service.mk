DAEMON_syslogd_COMMAND?=/usr/sbin/syslogd
DAEMON_syslogd_ENABLE?=yes
DAEMON_syslogd_FLAGS?=-ss8cc

syslogd: ${_EARLYSERVICE} newsyslog

syslogd_exit: ${_SERVICE_EXIT} sensorsd_exit hotplugd_exit
