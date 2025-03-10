#DAEMON_unbound_ACHORFLAGS
DAEMON_unbound_COMMAND?=/usr/local/sbin/unbound
DAEMON_unbound_CONFIG=/usr/local/etc/unbound/unbound.conf
DAEMON_unbound_FLAGS?=-c ${DAEMON_unbound_CONFIG}
DAEMON_unbound_FOREGROUND?=-dp
#DAEMON_unbound_USER?=unbound

unbound: ${_SERVICE}
	su -m unbound -c "/usr/local/sbin/unbound-anchor ${DAEMON_unbound_ACHORFLAGS}"
	/usr/local/sbin/unbound-checkconf ${DAEMON_unbound_CONFIG} >/dev/null
