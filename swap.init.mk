swap: savecore
.if ${:!sysctl -n vm.swap_enabled!}} != 0
	echo "MRC:$@> Enabling swap."; \
	swapon -a
.endif
