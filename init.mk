# Meta targets

TARGETS+=adjkerntz bootfs cleanvar cleartmp cloned devfs dmesg dumpon fsck hostname ifconfig kld ldconfig mixer mount mountlate msgs newsyslog nextboot nfsclient pwcheck random root rpc_umntall runshm savecore swap sysctl sysdb wlans

DAEMON: pwcheck sysctl sysdb NETWORK SERVERS ldconfig nfsclient cleartmp

LOGIN: DAEMON dntpd msgs powerd

NETWORK: ifconfig devd hostname

SERVERS: swap mountlate syslogd newsyslog

SERVICE: ifconfig mount random hostname cleanvar

# regular targets

adjkerntz: random mount
	echo "MRC:$@> Adjust kernel timezone."
	adjkerntz -i

bootfs: fsck
	echo "MRC:$@> Checking whether we need /boot mounted."
	mount -vadr | grep -q ' /boot$$' && mount -r /boot || true

CLEANVAR_DIRS?=/var/run /var/spool/lock /var/spool/uucp/.Temp

cleanvar: mount
	echo "MRC:$@> Cleaning 'var's."
.for dir in ${CLEANVAR_DIRS}
	-test -d ${dir} && find ${dir} -mindepth 1 -delete
.endfor
	install -m644 /dev/null /var/run/utmpx

cleartmp: mountlate
	echo "MRC:$@> Clearing tmp."; \
	find -x /tmp -mindepth 1 ! -name lost+found \
	    ! -name snapshots ! -path "./snapshots/*" \
	    ! -name quota.user ! -name quota.group \
	    -delete -type d -prune ;\
	  rm -f /tmp/.X*-lock ;\
	  rm -fr /tmp/.X11-unix ;\
	  mkdir -m 1777 /tmp/.X11-unix

cloned: kld
	echo "MRC:$@> Cloning interfaces: ${CLONED_INTERFACES}"
.for iface in ${CLONED_INTERFACES}
	ifconfig ${iface} create
.endfor

DEVFS_CONFIG_FILES?=/etc/defaults/devfs.conf /etc/devfs.conf

devfs:
	echo "MRC:$@> Applying rules: ${DEVFS_CONFIG_FILES}"
.for file in ${DEVFS_CONFIG_FILES}
.if exists(${file})
	devfsctl -a -f ${file}
.endif
.endfor

DMESG_FILE?=/var/run/dmesg.boot

dmesg: mountlate
	echo "MRC:$@> Writing dmesg."
	umask 022 ; dmesg -a >> ${DMESG_FILE}

DUMPDEV?=no

dumpon: random
	test -e ${DUMPDEV} && { \
	  echo "MRC:$@> Setting dumpon device to ${DUMPDEV}"; \
	  dumpon -v ${DUMPDEV}; \
	} || true

fsck:
	echo "MRC:$@> Checking disks." ;\
	fsck -p ;\
	case $$? in \
	0) ;; \
	2) exit 1 \
	   ;; \
	4) echo "Rebooting..." ;\
	   reboot ;\
	   echo "Reboot failed; help!" ;\
	   exit 1 \
	   ;; \
	8) if [ -n "$${FSCK_Y_ENABLE}" ]; then \
	     echo "File system preen failed, trying fsck -y." ;\
	     fsck -y || {\
	       echo "Automatic file system check failed; help!" ;\
	       exit 1 ;\
	     }\
	   else \
	     echo "Automatic file system check failed; help!" ;\
	     exit 1 ;\
	   fi ;\
	   ;; \
	12) echo "Boot interrupted." ;\
	   exit 1 \
	   ;; \
	130) exit 1 \
	   ;; \
	*) echo "Unknown error, help!" ;\
	   exit 1 \
	   ;; \
	esac

HOSTNAME?=Amnesiac

hostname:
	echo "MRC:$@> Setting to ${HOSTNAME}."
	hostname ${HOSTNAME}

IFCONFIG_IFACES?=lo0
IFCONFIG_lo0?=inet 127.0.0.1/8 up

ifconfig: adjkerntz wlans cloned kld
	echo "MRC:$@> Starting interfaces: ${IFCONFIG_IFACES}"
.for iface in ${IFCONFIG_IFACES}
.for item in ${IFCONFIG_${iface}:tW:ts;}
	ifconfig ${iface} ${item}
.endfor
.undef _IFCONFIG_ARGS
.endfor

kld: bootfs
.if defined(KLD_LIST)
	echo "MRC:$@> Loading kernel modules: ${KLD_LIST}"
	kldload -n ${KLD_LIST}
.endif

LDCONFIG_PATHS?=/lib /usr/lib /usr/local/lib /usr/pkg/lib
LDCONFIG_LOCAL_DIRS?=/usr/local/libdata/ldconfig

.for path in ${LDCONFIG_PATHS} /etc/ld-elf.so.conf
.if exists(${path})
ldc+=${path}
.endif
.endfor

.for dir in ${LDCONFIG_LOCAL_DIRS}
.if exists(${dir})
ldc+=${:!find ${dir} -type f!}
.endif
.endfor

ldconfig: mountlate
	echo "MRC:$@> Initializing shared libraries: ${ldc}"; \
	ldconfig -elf ${ldc}

mixers=${:!find /dev -name 'mixer*'!:S/\/dev\///}

mixer: mount cleanvar
	echo "MRC:$@> Restoring levels."
.for mixer in ${mixers}
	-test -f /var/db/${mixer}-state && mixer -f /dev/${mixer} `cat /var/db/${mixer}-state`
.endfor

NETFS_TYPES?=nfs:NFS smbfs:SMB

excludes=${NETFS_TYPES:C/:.*//}

mount: root
	echo "MRC:$@> Mount local FS."
	mount -a -t no${excludes:ts,}

mountlate: NETWORK mount cleanvar runshm devd
	echo "MRC:$@> Mount late FS."
	mount -a

msgs: mount
	echo "MRC:$@> Making bounds." ;\
	  test ! -d /var/msgs -o -f /var/msgs/bound -o -L /var/msgs/bounds || \
	  echo 0 > /var/msgs/bounds

NEWSYSLOG_ENABLE?=no

newsyslog: mountlate sysdb
	test -z "$${NEWSYSLOG_ENABLE}" || \
	  echo "MRC:$@> Trimming log files." ;\
	  /usr/sbin/newsyslog ${NEWSYSLOG_FLAGS}

nextboot: mount
.if exists(/boot/nextkernel)
	echo "MRC:$@> Removing nextboot setting."
	rm -f /boot/nextkernel
.endif

NFSCLIENT_ENABLE?=no

.if empty(NFSCLIENT_ENABLE:tl:Mno)
DAEMON_rpcbind_ENABLE=yes
.endif

nfsclient: NETWORK rpcbind rpc_umntall
	test -z "$${NFSCLIENT_ENABLE}" || kldload -n nfs

pwcheck: mountlate syslogd
	echo "MRC:$@> Checking password lock file."
.if exists(/etc/ptmp)
	logger -s -p auth.err "password file may be incorrect -- /etc/ptmp exists"
.endif

ENTROPY_FILE?=/var/db/entropy/random
ENTROPY_DIR?=/var/db/entropy

random: mount devfs
	echo "MRC:$@> Seeding."
	sysctl kern.seedenable=1 > /dev/null
	( ps -fauxww; ${SYSCTL} -a; date; df -ib; dmesg; ps -fauxww; ) 2>&1 | dd status=none of=/dev/random bs=8k
	cat /bin/ls | dd status=none of=/dev/random bs=8k
.if exists(ENTROPY_DIR)
.for file in ${:!find ${ENTROPY_DIR} -type f!}
	dd status=none if=${file} of=/dev/random bs=8k
.endfor
.elif exists(ENTROPY_FILE)
	dd status=none if=${ENTROPY_FILE} of=/dev/random bs=8k
.endif
	sysctl kern.seedenable=0 > /dev/null

root: fsck bootfs
	echo "MRC:$@> Mount root R/W."
	mount -uo rw /
	umount -a

rpc_umntall: mountlate NETWORK rpcbind
.if empty(RPC_UMNTALL_ENABLE:tl:Mno)
	echo "MRC:$@> Sending RPC unmount notifications."; \
	test -f /var/db/mounttab || true && \
	  rpc.umntall -k &
.endif

runshm: cleanvar
	echo "MRC:$@> Mount and populate /var/run/shm."; \
	mkdir -p /var/run/shm; \
	mount_tmpfs -m 01777 dummy /var/run/shm; \
	mkdir -p -m 01777 /var/run/shm/tmp; \

DUMPDIR?=/var/crash
CRASHINFO_ENABLE?=no

savecore: dumpon
.if empty(DUMPDEV:tl:Mno) && exists(${DUMPDEV}) && exists(${DUMPDIR})
	echo "MRC:$@> Saving coredump."; \
	savecore ${DUMPDIR} ${DUMPDEV}
.if empty(CRASHINFO_ENABLE:tl:Mno)
	crashinfo -d ${DUMPDIR}
.endif
.endif

swap: savecore
.if ${:!sysctl -n vm.swap_enabled!}} != 0
	echo "MRC:$@> Enabling swap."; \
	swapon -a
.endif

sysctl: kld root
.if exists(/etc/sysctl.conf)
	echo "MRC:$@> Setting sysctl defaults."; \
	awk '$$0~/^[ ]*(#.*)?$$/{next}{print}' < /etc/sysctl.conf | xargs -n1 sysctl
.endif

sysdb: mountlate
	echo "MRC:$@> Building databases."; \
	dev_mkdb; \
	install -c -m 644 -g wheel /dev/null /var/run/utmpx

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
