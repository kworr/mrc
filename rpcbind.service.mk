DAEMON_rpcbind_COMMAND?=/usr/sbin/rpcbind
DAEMON_rpcbind_FLAGS?=-d

DAEMON_syslogd_DEPS+=rpcbind

rpcbind: ${_EARLYSERVICE} NETWORK syslogd

NETWORK_EXIT: rpcbind_exit
