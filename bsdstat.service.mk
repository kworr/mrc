DAEMON_bsdstats_COMMAND?=/usr/local/etc/periodic/monthly/300.statistics
DAEMON_bsdstats_ENABLE?=no
DAEMON_bsdstats_FLAGS?=-nodelay

bsdstats: _service_plain
bsdstats_exit:
