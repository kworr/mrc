DAEMON_dntpd_COMMAND?=/usr/sbin/dntpd
DAEMON_dntpd_FOREGROUND?=-F

dntpd: ${_SERVICE} NETWORK

NETWORK_EXIT: dntpd_exit
