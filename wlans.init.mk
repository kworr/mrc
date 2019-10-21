wlans: kld
	echo "MRC:$@> Configuring wlans."; \
	for dev in `sysctl -n net.wlan.devices`; do \
	  eval all_wlans=\$${WLANS_$${dev}}; \
	  for wlan in $${all_wlans}; do \
	    eval wlan_args=\$${WLANS_$${wlan}_ARGS}; \
	    ifconfig $${wlan} create wlandev $${dev} $${wlan_args}; \
	    ifconfig $${wlan} up; \
	  done; \
	done
