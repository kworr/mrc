DAEMON_wpa_supplicant_COMMAND?=/usr/local/sbin/wpa_supplicant /usr/sbin/wpa_supplicant
DAEMON_wpa_supplicant_BACKGROUND?=-B
DAEMON_wpa_supplicant_FLAGS?=-M -iwlan* -Dbsd -c/etc/wpa_supplicant.conf

wpa_supplicant: ${_SERVICE}
