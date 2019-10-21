DMESG_FILE?=/var/run/dmesg.boot

dmesg: mountlate
	echo "MRC:$@> Writing dmesg."
	umask 022 ; dmesg -a >> ${DMESG_FILE}
