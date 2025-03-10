DAEMON_syncthing_COMMAND?=/usr/local/bin/syncthing
DAEMON_syncthing_FLAGS?=-home=${DAEMON_syncthing_HOME} -logfile=${DAEMON_syncthing_LOGFILE} --no-browser --no-default-folder --no-upgrade
DAEMON_syncthing_GROUP?=syncthing
DAEMON_syncthing_USER?=syncthing

DAEMON_syncthing_HOME?=/usr/local/etc/syncthing
DAEMON_syncthing_LOGFILE?=/var/log/syncthing.log

syncthing: ${_SERVICE}
	install -d -o ${DAEMON_syncthing_USER} -g ${DAEMON_syncthing_GROUP} ${DAEMON_syncthing_HOME}
	install -o ${DAEMON_syncthing_USER} -g ${DAEMON_syncthing_GROUP} /dev/null ${DAEMON_syncthing_LOGFILE}
	export HOME=/
