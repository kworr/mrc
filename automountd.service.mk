DAEMON_automountd_COMMAND?=/usr/sbin/automountd
DAEMON_automountd_MODULES=autofs

automountd: ${_SERVICE} # nfsclient -> DAEMON
	/usr/sbin/automount

NETWORK_EXIT: automountd_exit
