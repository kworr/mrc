rpc_umntall: mountlate NETWORK rpcbind
.if empty(RPC_UMNTALL_ENABLE:tl:Mno)
	echo "MRC:$@> Sending RPC unmount notifications."; \
	test -f /var/db/mounttab || true && \
	  rpc.umntall -k &
.endif
