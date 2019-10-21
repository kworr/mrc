sysctl: kld root
.if exists(/etc/sysctl.conf)
	echo "MRC:$@> Setting sysctl defaults."; \
	awk '$$0~/^[ ]*(#.*)?$$/{next}{print}' < /etc/sysctl.conf | xargs -n1 sysctl
.endif
