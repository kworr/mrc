DUMPDEV?=no

dumpon: random
	test -e ${DUMPDEV} && { \
	  echo "MRC:$@> Setting dumpon device to ${DUMPDEV}"; \
	  dumpon -v ${DUMPDEV}; \
	} || true
