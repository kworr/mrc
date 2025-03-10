DAEMON_postgres_COMMAND?=/usr/local/bin/pg_ctl
DAEMON_postgres_FLAGS?=-w -s -m fast -D ${DAEMON_postgres_DATA}
DAEMON_postgres_BACKGROUND?=start
DAEMON_postgres_USER?=postgres
DAEMON_postgres_GROUP?=postgres
DAEMON_postgres_DATA?=/var/db/postgres/data16

postgres: ${_SERVICE_PLAIN}

postgres_exit: ${_SERVICE_PLAIN_EXIT}
	$${CMD} stop
