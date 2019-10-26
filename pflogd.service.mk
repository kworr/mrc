DAEMON_pflogd_COMMAND?=/sbin/pflogd
DAEMON_pflogd_MODULES?=pf
DAEMON_pflogd_FLAGS?=-f /var/log/pflog

pflogd: root mount netif
.if !empty(PFLOG_ENABLE:tl:Mno)
	echo "MRC:$@> Configuring device." ;\
	kldload -n pf || exit 1 ;\
	ifconfig pflog0 up || { \
	  echo "MRC:$@> Failed to set up pflog0 device." ;\
	  exit 1 ;\
	}
.endif
