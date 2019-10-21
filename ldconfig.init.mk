LDCONFIG_PATHS?=/lib /usr/lib /usr/local/lib /usr/pkg/lib
LDCONFIG_LOCAL_DIRS?=/usr/local/libdata/ldconfig

.for path in ${LDCONFIG_PATHS} /etc/ld-elf.so.conf
.if exists(${path})
ldc+=${path}
.endif
.endfor

.for dir in ${LDCONFIG_LOCAL_DIRS}
.if exists(${dir})
ldc+=${:!find ${dir} -type f!}
.endif
.endfor

ldconfig: mountlate
	echo "MRC:$@> Initializing shared libraries: ${ldc}"; \
	ldconfig -elf ${ldc}
