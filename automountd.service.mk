DAEMON_automountd_COMMAND?=/usr/sbin/automountd
DAEMON_automountd_ENABLE?=no
DAEMON_automountd_MODULES=autofs

automountd: _service # nfsclient -> DAEMON
	test -z "$${DAEMON_$@_ENABLE}" || /usr/sbin/automount