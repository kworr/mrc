.if exists(/usr/local/sbin/wpa_supplicant)
DAEMON_wpa_supplicant_COMMAND?=/usr/local/sbin/wpa_supplicant
.elif exists(/usr/sbin/wpa_supplicant)
DAEMON_wpa_supplicant_COMMAND?=/usr/sbin/wpa_supplicant
.endif
DAEMON_wpa_supplicant_BACKGROUND?=-B
DAEMON_wpa_supplicant_ENABLE?=no
DAEMON_wpa_supplicant_FLAGS?=-M -iwlan* -Dbsd -c/etc/wpa_supplicant.conf

wpa_supplicant: ${_SERVICE}
