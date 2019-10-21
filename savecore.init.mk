DUMPDIR?=/var/crash
CRASHINFO_ENABLE?=no

savecore: dumpon
.if empty(DUMPDEV:tl:Mno) && exists(${DUMPDEV}) && exists(${DUMPDIR})
	echo "MRC:$@> Saving coredump."; \
	savecore ${DUMPDIR} ${DUMPDEV}
.if empty(CRASHINFO_ENABLE:tl:Mno)
	crashinfo -d ${DUMPDIR}
.endif
.endif
