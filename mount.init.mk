NETFS_TYPES?=nfs:NFS smbfs:SMB

excludes=${NETFS_TYPES:C/:.*//}

mount: root
	echo "MRC:$@> Mount local FS."
	mount -a -t no${excludes:ts,}
