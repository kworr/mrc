DAEMON_rpcbind_COMMAND?=/usr/sbin/rpcbind
DAEMON_rpcbind_ENABLE?=no
DAEMON_rpcbind_FLAGS?=-d

rpcbind: _earlyservice NETWORK syslogd