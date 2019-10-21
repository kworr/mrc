nextboot: mount
.if exists(/boot/nextkernel)
	echo "MRC:$@> Removing nextboot setting."
	rm -f /boot/nextkernel
.endif
