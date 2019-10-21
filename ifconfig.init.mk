IFCONFIG_IFACES?=lo0
IFCONFIG_lo0?=inet 127.0.0.1/8 up

ifconfig: adjkerntz wlans cloned kld
	echo "MRC:$@> Starting interfaces: ${IFCONFIG_IFACES}"
.for iface in ${IFCONFIG_IFACES}
	ifconfig ${iface} ${IFCONFIG_${iface}}
.endfor
