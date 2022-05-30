DAEMON_rpcbind_COMMAND?=/usr/sbin/rpcbind
DAEMON_rpcbind_ENABLE?=no
DAEMON_rpcbind_FLAGS?=-d

rpcbind: ${_EARLYSERVICE} NETWORK syslogd

rpcbind_exit: ${_SERVICE_EXIT} mountd_exit nfsd_exit

NETWORK_EXIT: rpcbind_exit
