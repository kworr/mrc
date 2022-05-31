DAEMON_sensorsd_COMMAND?=/usr/sbin/sensorsd
DAEMON_sensorsd_FOREGROUND?=-d

DAEMON_syslogd_DEPS+=sensorsd

sensorsd: ${_SERVICE} syslogd
