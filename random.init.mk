ENTROPY_FILE?=/var/db/entropy/random
ENTROPY_DIR?=/var/db/entropy

random: mount devfs
	echo "MRC:$@> Seeding."
	sysctl kern.seedenable=1 > /dev/null
	( ps -fauxww; ${SYSCTL} -a; date; df -ib; dmesg; ps -fauxww; ) 2>&1 | dd status=none of=/dev/random bs=8k
	cat /bin/ls | dd status=none of=/dev/random bs=8k
.if exists(ENTROPY_DIR)
.for file in ${:!find ${ENTROPY_DIR} -type f!}
	dd status=none if=${file} of=/dev/random bs=8k
.endfor
.elif exists(ENTROPY_FILE)
	dd status=none if=${ENTROPY_FILE} of=/dev/random bs=8k
.endif
	sysctl kern.seedenable=0 > /dev/null