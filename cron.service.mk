DAEMON_cron_COMMAND?=/usr/sbin/cron
DAEMON_cron_FLAGS?=-s

cron: ${_SERVICE} LOGIN
