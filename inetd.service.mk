DAEMON_inetd_COMMAND?=/usr/sbin/inetd
DAEMON_inetd_enable?=no
DAEMON_inetd_FLAGS?=-C 60

inetd: ${_SERVICE} LOGIN

LOGIN_EXIT: inetd_exit
