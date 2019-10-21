DAEMON_powerd_COMMAND?=/usr/sbin/powerd
DAEMON_powerd_ENABLE?=no

powerd: _service # DAEMON -> _service
