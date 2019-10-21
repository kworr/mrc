bootfs: fsck
	echo "MRC:$@> Checking whether we need /boot mounted."
	mount -vadr | grep -q ' /boot$$' && mount -r /boot || true
