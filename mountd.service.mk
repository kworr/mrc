DAEMON_mountd_COMMAND?=/sbin/mountd
DAEMON_mountd_FLAGS?=-r

.if empty(DAEMON_mountd_ENABLE:tl:Mno)
DAEMON_rpcbind_ENABLE=yes

DAEMON_rpcbind_DEPS+=mountd
.endif

mountd: rpcbind NETWORK SERVERS ${_SERVICE} # mountlate -> SERVERS
	rm -f /var/db/mountdtab ;\
	( umask 022; touch /var/db/mountdtab; ) ;\
	:

NETWORK_EXIT: mountd_exit
