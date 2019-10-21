NFSCLIENT_ENABLE?=no

.if empty(NFSCLIENT_ENABLE:tl:Mno)
DAEMON_rpcbind_ENABLE=yes
.endif

nfsclient: NETWORK rpcbind rpc_umntall
	test -z "$${NFSCLIENT_ENABLE}" || kldload -n nfs
