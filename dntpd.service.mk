DAEMON_dntpd_COMMAND?=/usr/sbin/dntpd
DAEMON_dntpd_FOREGROUND?=-F

dntpd: _service NETWORK
