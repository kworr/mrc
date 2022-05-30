DAEMON_sensorsd_COMMAND?=/usr/sbin/sensorsd
DAEMON_sensorsd_FOREGROUND?=-d

sensorsd: ${_SERVICE} syslogd
