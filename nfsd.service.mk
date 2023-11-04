DAEMON_nfsd_COMMAND?=/sbin/nfsd
DAEMON_nfsd_FLAGS?=-u -t -n 4

.if empty(DAEMON_nfsd_ENABLE:Uno:tl:Mno)
DAEMON_mountd_DEPS+=nfsd
DAEMON_rpcbind_DEPS+=nfsd

DAEMON_rpcbind_ENABLE=yes
DAEMON_mountd_ENABLE=yes
.endif

nfsd: mountd ${_SERVICE} rpcbind
.if empty(NFS_RESERVED_PORT_ONLY:tl:Mno)
	sysctl vfs.nfs.nfs_privport=1
.endif
