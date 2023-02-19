DAEMON_pcdm_COMMAND?=/usr/local/bin/xinit
DAEMON_pcdm_FLAGS?=/usr/local/bin/PCDM-session -once -- :0 -auth ${XAUTHORITY} -nolisten tcp vt9
DAEMON_pcdm_BACKGROUND?=-d

DAEMON_dbus_DEPS+=pcdm

XAUTHORITY:=/var/run/pcdm.auth-${:!openssl rand -hex 64!}

pcdm: ${_SERVICE} dbus
	rm -f /var/run/pcdm.auth*
	touch ${XAUTHORITY}
	xauth -f ${XAUTHORITY} add :0 MIT-MAGIC-COOKIE-1 ${:!openssl rand -hex 64!}

.export XAUTHORITY
