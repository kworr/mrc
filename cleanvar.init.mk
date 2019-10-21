CLEANVAR_DIRS?=/var/run /var/spool/lock /var/spool/uucp/.Temp

cleanvar: mount
	echo "MRC:$@> Cleaning 'var's."
.for dir in ${CLEANVAR_DIRS}
	-test -d ${dir} && find ${dir} -mindepth 1 -delete
.endfor
	install -m644 /dev/null /var/run/utmpx
