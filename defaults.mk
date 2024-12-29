# global

NCPU=${:!sysctl -n hw.ncpu!}

# cleanvar
CLEANVAR_DIRS?=/var/run /var/spool/lock /var/spool/uucp/.Temp

# cloned
CLONED_INTERFACES?=

# devfs
DEVFS_CONFIG_FILES?=/etc/defaults/devfs.conf /etc/devfs.conf

# dmesg
DMESG_FILE?=/var/run/dmesg.boot

# dumpon
DUMPDEV?=no

# fsck
FSCK_Y_ENABLE?=no

# hostname
HOSTNAME?=Amnesiac

# HAS_INET6
HAS_INET6?=${:!sysctl -q net.inet6 >/dev/null && echo yes || echo no!}
PREFER?=IPV6 # or IPV4

# kld
KLD_LIST?=

# ldconfig
LDCONFIG_PATHS?=/lib /usr/lib /usr/local/lib /usr/pkg/lib
LDCONFIG_LOCAL_DIRS?=/usr/local/libdata/ldconfig

# moused
MOUSED_PORT?=/dev/ums0
MOUSED_TYPE?=auto

# mount
NETFS_TYPES?=nfs:NFS smbfs:SMB

# newsyslog
NEWSYSLOG_ENABLE?=no
NEWSYSLOG_FLAGS?=

# nfsclient
NFSCLIENT_ENABLE?=no

# netif
IFCONFIG_IFACES?=lo0
IFCONFIG_lo0?=inet 127.0.0.1/8; up

# pf
PF_ENABLE?=no
PF_RULES?=/etc/pf.conf
PF_FLAGS?=

# random
ENTROPY_DIR?=/var/db/entropy
ENTROPY_FILE?=/var/db/entropy/random

# rpc_umntall
RPC_UMNTALL_ENABLE?=no

# savecore
CRASHINFO_ENABLE?=no
DUMPDIR?=/var/crash

# tmpfs
TMPFS_TMP_ENABLE?=no
TMPFS_VAR_RUN_ENABLE?=no

# zfs
ZFS_ENABLE?=no
