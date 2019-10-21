root: fsck bootfs
	echo "MRC:$@> Mount root R/W."
	mount -uo rw /
	umount -a
