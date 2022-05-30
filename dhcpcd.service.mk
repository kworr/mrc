DAEMON_dhcpcd_COMMAND?=/sbin/dhcpcd
DAEMON_dhcpcd_ENABLE?=no
DAEMON_dhcpcd_FLAGS?="-h${HOSTNAME}"
DAEMON_dhcpcd_BACKGROUND?=-b
DAEMON_dhcpcd_FOREGROUND?=-B

dhcpcd: ${_SERVICE} NETWORK SERVICE # mount -> SERVICE, cleanvar -> SERVICE

NETWORK_EXIT: dhcpcd_exit
SERVICE_EXIT: dhcpcd_exit
