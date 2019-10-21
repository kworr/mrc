DAEMON_mountd_COMMAND?=/sbin/mountd
DAEMON_mountd_ENABLE?=no
DAEMON_mountd_FLAGS?=-r

.if empty(DAEMON_mountd_ENABLE:tl:Mno)
DAEMON_rpcbind_ENABLE=yes
.endif

mountd: rpcbind NETWORK SERVERS _service # mountlate -> SERVERS
	test -z "$${DAEMON_$@_ENABLE}" || { \
	  rm -f /var/db/mountdtab; \
	  ( umask 022 ; touch /var/db/mountdtab ); \
	}
