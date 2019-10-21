DEVFS_CONFIG_FILES?=/etc/defaults/devfs.conf /etc/devfs.conf

devfs:
	echo "MRC:$@> Applying rules: ${DEVFS_CONFIG_FILES}"
.for file in ${DEVFS_CONFIG_FILES}
.if exists(${file})
	devfsctl -a -f ${file}
.endif
.endfor
