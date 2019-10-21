NEWSYSLOG_ENABLE?=no

newsyslog: mountlate sysdb
	test -z "$${NEWSYSLOG_ENABLE}" || \
	  echo "MRC:$@> Trimming log files." ;\
	  /usr/sbin/newsyslog ${NEWSYSLOG_FLAGS}
