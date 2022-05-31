DAEMON_hotplugd_COMMAND?=/usr/sbin/hotplugd

DAEMON_syslogd_DEPS+=hotplugd
DAEMON_udevd_DEPS+=hotplugd

hotplugd: ${_SERVICE} syslogd udevd
