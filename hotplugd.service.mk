DAEMON_hotplugd_COMMAND?=/usr/sbin/hotplugd

hotplugd: ${_SERVICE} syslogd udevd
