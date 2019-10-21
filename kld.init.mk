kld: bootfs
.if defined(KLD_LIST)
	echo "MRC:$@> Loading kernel modules: ${KLD_LIST}"
	kldload -n ${KLD_LIST}
.endif
