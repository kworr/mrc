DAEMON_dhcpcd_COMMAND?=/sbin/dhcpcd
DAEMON_dhcpcd_ENABLE?=no
DAEMON_dhcpcd_FLAGS?=-B

dhcpcd: _service NETWORK SERVICE # mount -> SERVICE, cleanvar -> SERVICE
