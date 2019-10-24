DAEMON_dhcpcd_COMMAND?=/sbin/dhcpcd
DAEMON_dhcpcd_ENABLE?=no
DAEMON_dhcpcd_BACKGROUND?=-b
DAEMON_dhcpcd_FOREGROUND?=-B

dhcpcd: _service NETWORK SERVICE # mount -> SERVICE, cleanvar -> SERVICE
