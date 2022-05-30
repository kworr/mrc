DAEMON_bsdstat_COMMAND?=/usr/local/etc/periodic/monthly/300.statistics
DAEMON_bsdstat_ENABLE?=no
DAEMON_bsdstat_FLAGS?=-nodelay

bsdstat: ${_SERVICE_PLAIN}
bsdstat_exit:
