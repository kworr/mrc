msgs: mount
	echo "MRC:$@> Making bounds." ;\
	  test ! -d /var/msgs -o -f /var/msgs/bound -o -L /var/msgs/bounds || \
	  echo 0 > /var/msgs/bounds
