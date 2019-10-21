DAEMON_dntpd_COMMAND?=/usr/sbin/dntpd
DAEMON_dntpd_FLAGS?=-F

dntpd: _service NETWORK
