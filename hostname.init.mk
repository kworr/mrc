HOSTNAME?=Amnesiac

hostname:
	echo "MRC:$@> Setting to ${HOSTNAME}."
	hostname ${HOSTNAME}
