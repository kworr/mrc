mixers=${:!find /dev -name 'mixer*'!:S/\/dev\///}

mixer: mount cleanvar
	echo "MRC:$@> Restoring levels."
.for mixer in ${mixers}
	-test -f /var/db/${mixer}-state && mixer -f /dev/${mixer} `cat /var/db/${mixer}-state`
.endfor
