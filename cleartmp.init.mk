cleartmp: mountlate
	echo "MRC:$@> Clearing tmp."; \
	find -x /tmp -mindepth 1 ! -name lost+found \
	    ! -name snapshots ! -path "./snapshots/*" \
	    ! -name quota.user ! -name quota.group \
	    -exec rm -rf -- {} \; -type d -prune); \
	  rm -f /tmp/.X*-lock; \
	  rm -fr /tmp/.X11-unix; \
	  mkdir -m 1777 /tmp/.X11-unix
