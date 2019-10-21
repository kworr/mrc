cloned: kld
	echo "MRC:$@> Cloning interfaces: ${CLONED_INTERFACES}"
.for iface in ${CLONED_INTERFACES}
	ifconfig ${iface} create
.endfor
