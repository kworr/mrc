runshm: cleanvar
	echo "MRC:$@> Mount and populate /var/run/shm."; \
	mkdir -p /var/run/shm; \
	mount_tmpfs -m 01777 dummy /var/run/shm; \
	mkdir -p -m 01777 /var/run/shm/tmp; \