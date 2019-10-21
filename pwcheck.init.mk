pwcheck: mountlate syslogd
	echo "MRC:$@> Checking password lock file."
.if exists(/etc/ptmp)
	logger -s -p auth.err "password file may be incorrect -- /etc/ptmp exists"
.endif
