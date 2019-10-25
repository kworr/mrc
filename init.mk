# Meta targets

TARGETS+=adjkerntz bootfs cleanvar cleartmp cloned devfs dmesg dumpon fsck \
	hostname kld ldconfig microcode mixer mount mountlate msgs netif \
	newsyslog nextboot nfsclient pf pwcheck random root rpc_umntall runshm \
	savecore swap sysctl sysdb wlans zfs

DAEMON: pwcheck sysctl sysdb NETWORK SERVERS ldconfig nfsclient cleartmp pflogd

LOGIN: DAEMON dntpd msgs powerd pflogd

NETWORK: netif devd hostname

SERVERS: swap mountlate syslogd newsyslog

SERVICE: netif mount random hostname cleanvar

# regular targets

adjkerntz: random mount
	echo "MRC:$@> Adjust kernel timezone."
	adjkerntz -i

bootfs: fsck
	echo "MRC:$@> Checking whether we need /boot mounted."
	mount -vadr | grep -q ' /boot$$' && mount -r /boot || true

cleanvar: mount
	echo "MRC:$@> Cleaning 'var's."
.for dir in ${CLEANVAR_DIRS}
	test -d ${dir} && find ${dir} -mindepth 1 -delete || true
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
.if !empty(CLONED_INTERFACES)
	echo "MRC:$@> Cloning interfaces: ${CLONED_INTERFACES}"
.for iface in ${CLONED_INTERFACES}
	ifconfig ${iface} create
.endfor
.endif

devfs:
	echo "MRC:$@> Applying rules: ${DEVFS_CONFIG_FILES}"
.for file in ${DEVFS_CONFIG_FILES}
.if exists(${file})
	devfsctl -a -f ${file}
.endif
.endfor

dmesg: mountlate
.if !empty(DMESG_FILE)
	echo "MRC:$@> Writing dmesg."
	umask 022 ; dmesg -a >> ${DMESG_FILE}
.endif

dumpon: random
.if !empty(DUMPDEV)
	test -e ${DUMPDEV} && { \
	  echo "MRC:$@> Setting dumpon device to ${DUMPDEV}"; \
	  dumpon -v ${DUMPDEV}; \
	} || true
.endif

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

hostname:
	echo "MRC:$@> Setting to ${HOSTNAME}."
	hostname ${HOSTNAME}

kld: bootfs
.if defined(KLD_LIST)
	echo "MRC:$@> Loading kernel modules: ${KLD_LIST}"
	kldload -n ${KLD_LIST}
.endif

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

microcode: mountlate
.if exists(/usr/local/share/cpucontrol)
	echo "MRC:$@> Updating." ;\
	kldload -n cpuctl || exit 1 ;\
	for cpu in $$(jot "$$(sysctl -n hw.ncpu)" 0); do \
	  ( cpucontrol -u -d /usr/local/share/cpucontrol /dev/cpuctl$${cpu} \
	      || exit 1 \
	  ) | grep -v '^TEST' ;\
	  cpucontrol -e /dev/cpuctl$${cpu} || exit 1 ;\
	done
.endif

mixers=${:!find /dev -name 'mixer*'!:S/\/dev\///}

mixer: mount cleanvar
	echo "MRC:$@> Restoring levels."
.for mixer in ${mixers}
	test -f /var/db/${mixer}-state || true && mixer -f /dev/${mixer} \
	  `cat /var/db/${mixer}-state`
.endfor

excludes=${NETFS_TYPES:C/:.*//}

mount: root zfs
	echo "MRC:$@> Mount local FS."
	mount -a -t no${excludes:ts,}

mountlate: NETWORK mount cleanvar runshm devd
	echo "MRC:$@> Mount late FS."
	mount -a

msgs: mount
	echo "MRC:$@> Making bounds." ;\
	  test ! -d /var/msgs -o -f /var/msgs/bound -o -L /var/msgs/bounds || \
	  echo 0 > /var/msgs/bounds

newsyslog: mountlate sysdb
	test -z "$${NEWSYSLOG_ENABLE}" || \
	  echo "MRC:$@> Trimming log files." ;\
	  /usr/sbin/newsyslog ${NEWSYSLOG_FLAGS}

nextboot: mount
.if exists(/boot/nextkernel)
	echo "MRC:$@> Removing nextboot setting."
	rm -f /boot/nextkernel
.endif

.if empty(NFSCLIENT_ENABLE:tl:Mno)
DAEMON_rpcbind_ENABLE=yes
.endif

nfsclient: NETWORK rpcbind rpc_umntall
	test -z "$${NFSCLIENT_ENABLE}" || kldload -n nfs

netif: adjkerntz wlans cloned kld
	echo "MRC:$@> Starting interfaces: ${IFCONFIG_IFACES}"
.for iface in ${IFCONFIG_IFACES}
.for item in ${IFCONFIG_${iface}:tW:ts;}
	ifconfig ${iface} ${item}
.endfor
.undef _IFCONFIG_ARGS
.endfor

pf: pflogd
.if empty(PF_ENABLE:tl:Mno)
	echo "MRC:$@> Enabling and loading rules." ;\
	kldload -n pf || exit 1 ;\
	test -r ${PF_RULES} || {\
	  echo "MRC:$@> Can't find file with rules at ${PF_RULES}." ;\
	  exit 1 ;\
	} ;\
	pfctl -Fa || exit 1 ;\
	pfctl -f ${PF_RULES} ${PF_FLAGS} || exit 1 ;\
	pfctl -Si | grep -q Enabled && pfctl -e
.endif

pwcheck: mountlate syslogd
	echo "MRC:$@> Checking password lock file."
.if exists(/etc/ptmp)
	logger -s -p auth.err "password file may be incorrect -- /etc/ptmp \
	  exists"
.endif

random: mount devfs
	echo "MRC:$@> Seeding." ;\
	sysctl kern.seedenable=1 > /dev/null ;\
	( ps -fauxww; sysctl -a; date; df -ib; dmesg; ps -fauxww; ) 2>&1 | \
	  dd status=none of=/dev/random bs=8k ;\
	dd if=/bin/ps status=none of=/dev/random bs=8k ;\
	test -d $${ENTROPY_DIR} && {\
	  find $${ENTROPY_DIR} -type f |\
	  xargs -n1 -Ifoo dd status=none if=foo of=/dev/random bs=8k ;\
	} || {\
	  dd status=none if=${ENTROPY_FILE} of=/dev/random bs=8k ;\
	} ;\
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
	awk '$$0~/^[ ]*(#.*)?$$/{next}{print}' < /etc/sysctl.conf | \
	  xargs -n1 sysctl
.endif

sysdb: mountlate
	echo "MRC:$@> Building databases."; \
	dev_mkdb; \
	install -c -m 644 -g wheel /dev/null /var/run/utmpx

wlans: kld
	echo "MRC:$@> Configuring wlans."; \
	for dev in $$(sysctl -n net.wlan.devices); do \
	  eval all_wlans=\$${WLANS_$${dev}}; \
	  for wlan in $${all_wlans}; do \
	    eval wlan_args=\$${WLANS_$${wlan}_ARGS}; \
	    ifconfig $${wlan} create wlandev $${dev} $${wlan_args}; \
	    ifconfig $${wlan} up; \
	  done; \
	done

zfs:
.if empty(ZFS_ENABLE:tl:Mno)
	zfs mount -va || exit $$? ;\
	zfs share -a || exit $$? ;\
	test -r /etc/zfs/exports || touch /etc/zfs/exports
.endif
