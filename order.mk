# This file defines generic targets that should exist anyway and they default
# dependencies

# System portion

DAEMON: NETWORK SERVERS
LOGIN: DAEMON
NETWORK:
SERVERS:
SERVICE:

mount:
root:
netif:
newsyslog:

# Shutdown order

EXIT: DAEMON_EXIT NETWORK_EXIT SERVICE_EXIT

DAEMON_EXIT: LOGIN_EXIT

LOGIN_EXIT:

NETWORK_EXIT: DAEMON_EXIT

SERVICE_EXIT: DAEMON_EXIT
