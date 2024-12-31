# Meta targets

TARGETS:=adjkerntz bootfs cleanvar cleartmp cloned devfs dmesg dumpon fsck \
	hostname ip6addrctl kld ldconfig microcode mixer mount mountlate \
	mounttmpfs msgs netif newsyslog nextboot nfsclient pf pwcheck random root \
	runshm savecore swap sysctl sysdb udevd_check utmpx wlans zfs

OTHER_TARGETS+=mixer_exit nfsclient_exit random_exit

DAEMON: pwcheck sysctl sysdb NETWORK SERVERS ldconfig nfsclient cleartmp pflogd

LOGIN: DAEMON dntpd msgs powerd pflogd

NETWORK: netif devd hostname

SERVERS: swap mountlate syslogd newsyslog

SERVICE: netif mount random hostname cleanvar

# regular targets

adjkerntz: random mount
	echo "MRC:$@> Adjust kernel timezone."
	adjkerntz -i &

bootfs: fsck
	echo "MRC:$@> Checking whether we need /boot mounted."
	mount -vadr | grep -q ' /boot$$' && mount -r /boot || true

cleanvar: mount
	echo "MRC:$@> Cleaning '/var's."
.for dir in ${CLEANVAR_DIRS}
	if [ -d ${dir} ]; then \
		/rescue/find ${dir} -mindepth 1 -delete; \
	fi
.endfor

cleartmp: mountlate
	echo "MRC:$@> Clearing tmp."
	find -x /tmp -mindepth 1 ! -name lost+found ! -name snapshots \
		! -path "./snapshots/*" ! -name quota.user ! -name quota.group \
		-delete -type d -prune
	rm -fr /tmp/.X11-unix /tmp/.X*-lock
	mkdir -m 1777 /tmp/.X11-unix

cloned: kld
.if !empty(CLONED_INTERFACES)
	echo "MRC:$@> Cloning interfaces: ${CLONED_INTERFACES}"
.	for iface in ${CLONED_INTERFACES}
	ifconfig ${iface} create
.	endfor
.endif

devfs:
	echo "MRC:$@> Applying rules: ${DEVFS_CONFIG_FILES}"
.for file in ${DEVFS_CONFIG_FILES}
.	if exists(${file})
	devfsctl -a -f ${file}
.	endif
.endfor

dmesg: mountlate
.if !empty(DMESG_FILE)
	echo "MRC:$@> Writing dmesg."
	( umask 022 ; dmesg -a > ${DMESG_FILE} ;)
.endif

dumpon: random
.if !empty(DUMPDEV)
	if [ -e ${DUMPDEV} ]; then \
		echo "MRC:$@> Setting dumpon device to ${DUMPDEV}"; \
		dumpon -v ${DUMPDEV}; \
	fi
.endif

fsck:
	echo "MRC:$@> Checking disks."
	fsck -p; \
	case $$? in \
	0) ;; \
	2) exit 1 \
		;; \
	4) echo "Rebooting..."; \
		reboot ;\
		echo "Reboot failed; help!"; \
		exit 1 \
		;; \
	8) if [ -n "$${FSCK_Y_ENABLE}" ]; then \
			echo "File system preen failed, trying fsck -y."; \
			fsck -y || { \
				echo "Automatic file system check failed; help!"; \
				exit 1; \
			}; \
		else \
			echo "Automatic file system check failed; help!"; \
			exit 1; \
		fi \
		;; \
	12) echo "Boot interrupted."; \
		exit 1 \
		;; \
	130) exit 1 \
		;; \
	*) echo "Unknown error, help!"; \
		exit 1 \
		;; \
	esac

hostname:
	echo "MRC:$@> Setting to ${HOSTNAME}."
	hostname ${HOSTNAME}

ip6addrctl: root mount
.if empty(HAS_INET6:tl:Mno)
	/usr/sbin/ip6addrctl flush >/dev/null 2>&1
.	if !empty(PREFER:MIPV6)
	echo "MRC:$@> Setting v4/v6 address selection defaults (prefer v6)."
	printf "\
		::1/128			50	0\n\
		::/0			40	1\n\
		::ffff:0:0/96	35	4\n\
		2002::/16		30	2\n\
		2001::/32		5	5\n\
		fc00::/7		3	13\n\
		::/96			1	3\n\
		fec0::/10		1	11\n\
		3ffe::/16		1	12\n" |\
	/usr/sbin/ip6addrctl install /dev/stdin
.	elif !empty(PREFER:MIPV4)
	echo "MRC:$@> Setting v4/v6 address selection defaults (prefer v6)."
	printf "\
		::1/128			50	0\n\
		::/0			40	1\n\
		::ffff:0:0/96	100	4\n\
		2002::/16		30	2\n\
		2001::/32		5	5\n\
		fc00::/7		3	13\n\
		::/96			1	3\n\
		fec0::/10		1	11\n\
		3ffe::/16		1	12\n" |\
	/usr/sbin/ip6addrctl install /dev/stdin
.	else
	echo "MRC:$@> Setting v4/v6 address selection defaults (none)."
.	endif
.else
	echo "MRC:$@> No INET6 support in kernel."
.endif

kld: bootfs
.if defined(KLD_LIST)
	echo "MRC:$@> Loading kernel modules: ${KLD_LIST}"
.	for KLD in ${KLD_LIST}
	kldload -n ${KLD} || echo "MRC:$@> Failed to load module: ${KLD}"
.	endfor
	true
.endif

# ldconfig
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
	echo "MRC:$@> Initializing shared libraries: ${ldc}"
	ldconfig -elf ${ldc}

microcode: mountlate
	if [ -d /usr/local/share/cpucontrol ]; then \
		echo "MRC:$@> Updating microcode."; \
		if kldload -n cpuctl; then \
			for cpu in $$(jot ${NCPU} 0); do \
				cpucontrol -u /dev/cpuctl$${cpu}; \
			done; \
			for cpu in $$(jot ${NCPU} 1); do \
				cpucontrol -e /dev/cpuctl$${cpu}; \
			done \
		else \
			echo "MRC:$@> Failed to load [cpuctl]."; \
		fi \
	fi

mixer: mount cleanvar kld sysctl
	echo "MRC:$@> Restoring levels."
	for mixer in $$(find /dev -name 'mixer*' | sed 's|^/dev/||'); do \
		if [ -r /var/db/$${mixer}-state ]; then \
			mixer -f /dev/$${mixer} `cat /var/db/$${mixer}-state` || \
			echo "MRC:$@> /dev/$${mixer} config load failed."; \
		fi \
	done

mixer_exit:
	echo "MRC:$@> Saving mixer levels."
	for mixer in $$(find /dev -name 'mixer*' | sed 's|^/dev/||'); do \
		if [ -r /dev/$${mixer} ]; then \
			mixer -f /dev/$${mixer} -s > /var/db/$${mixer}-state; \
		fi \
	done

DAEMON_EXIT: mixer_exit

excludes=${NETFS_TYPES:C/:.*//}

mount: root zfs
	echo "MRC:$@> Mount local FS."
	mount -p | awk '$$1~/^map$$/{next}$$3!~/^(tmpfs|null|procfs)$$/{print"mount -uo rw "$$1}' | sh
	mount
	mount -a -t no${excludes:ts,}

mountlate: NETWORK mount cleanvar runshm devd mounttmpfs
	echo "MRC:$@> Mount late FS."
	mount -a

msgs: mount
	echo "MRC:$@> Making bounds."
	test ! -d /var/msgs -o -f /var/msgs/bound -o -L /var/msgs/bounds || \
		echo 0 > /var/msgs/bounds

newsyslog: mountlate sysdb
	if [ -n "$${NEWSYSLOG_ENABLE}" ]; then \
		echo "MRC:$@> Trimming log files."; \
		/usr/sbin/newsyslog ${NEWSYSLOG_FLAGS}; \
	fi

nextboot: mount
.if exists(/boot/nextkernel)
	echo "MRC:$@> Removing nextboot setting."
	rm -f /boot/nextkernel
.endif

.if empty(NFSCLIENT_ENABLE:tl:Mno)
DAEMON_rpcbind_ENABLE=yes
.endif

nfsclient: NETWORK rpcbind
	if [ -n "$${NFSCLIENT_ENABLE}" ]; then \
		kldload -n nfs; \
	fi

nfsclient_exit: DAEMON_EXIT
.if empty(RPC_UMNTALL_ENABLE:tl:Mno)
	echo "MRC:$@> Sending RPC unmount notifications."
	test -f /var/db/mounttab || true && rpc.umntall -k
.endif

NETWORK_EXIT: nfsclient_exit

netif: adjkerntz cloned ip6addrctl kld mounttmpfs utmpx wlans
	echo "MRC:$@> Starting interfaces: ${IFCONFIG_IFACES}"
.for iface in ${IFCONFIG_IFACES}
.	for item in ${IFCONFIG_${iface}:tW:ts;}
	ifconfig ${iface} ${item}
.	endfor
.	undef _IFCONFIG_ARGS
.endfor

pf: pflogd
.if empty(PF_ENABLE:tl:Mno)
	echo "MRC:$@> Enabling and loading rules."
	if kldload -n pf; then \
		if [ -r ${PF_RULES} ]; then \
			pfctl -Fa || exit 1; \
			pfctl -f ${PF_RULES} ${PF_FLAGS} || exit 1; \
			pfctl -Si | grep -q Enabled && pfctl -e; \
		else \
			echo "MRC:$@> Can't find file with rules at ${PF_RULES}."; \
			exit 1; \
		fi \
	else \
		echo "MRC:$@> Failed to load [pf]."; \
	fi
.endif

pwcheck: mountlate syslogd
	echo "MRC:$@> Checking password lock file."
.if exists(/etc/ptmp)
	logger -s -p auth.err \
		"password file may be incorrect -- /etc/ptmp exists"
.endif

random: mount devfs
	echo "MRC:$@> Seeding."
	sysctl kern.seedenable=1 > /dev/null
	( ps -fauxww; sysctl -a; date; df -ib; dmesg; ps -fauxww ;) 2>&1 | \
		dd status=none of=/dev/random bs=8k 2>/dev/null
	dd if=/bin/ps status=none of=/dev/random bs=8k 2>/dev/null
	if [ -d $${ENTROPY_DIR} ]; then \
		find $${ENTROPY_DIR} -type f | \
			xargs -n1 -Ifoo dd status=none if=foo of=/dev/random bs=8k 2>/dev/null; \
	else \
		if [ -r ${ENTROPY_FILE} ]; then \
			dd status=none if=${ENTROPY_FILE} of=/dev/random bs=8k 2>/dev/null; \
		fi \
	fi
	sysctl kern.seedenable=0 > /dev/null

random_exit:
	rm -f ${ENTROPY_FILE}; \
	( \
		umask 077; \
		dd if=/dev/random of=${ENTROPY_FILE} bs=8k count=1 2>/dev/null || \
			echo "MRC:$@> entropy file write failed."; \
	)

DAEMON_EXIT: random_exit

root: fsck bootfs
	echo "MRC:$@> Mount root R/W."
	mount -uo rw

savecore: dumpon
.if empty(DUMPDEV:tl:Mno) && exists(${DUMPDEV}) && exists(${DUMPDIR})
	echo "MRC:$@> Saving coredump."
	savecore ${DUMPDIR} ${DUMPDEV}
.if empty(CRASHINFO_ENABLE:tl:Mno)
	crashinfo -d ${DUMPDIR}
.endif
.endif

swap: savecore
.if ${:!sysctl -n vm.swap_enabled!}} != 0
	echo "MRC:$@> Enabling swap."
	swapon -a
.endif

sysctl: kld root
.if exists(/etc/sysctl.conf)
	echo "MRC:$@> Setting sysctl defaults."
	awk '$$0~/^[ ]*(#.*)?$$/{next}{print}' < /etc/sysctl.conf | \
		xargs -n1 sysctl
.endif

sysdb: mountlate
	echo "MRC:$@> Building databases."
	install -c -m 644 -g wheel /dev/null /var/run/utmpx

wlans: kld
	echo "MRC:$@> Configuring wlans." ;
	for dev in $$(sysctl -n net.wlan.devices); do \
		eval all_wlans=\$${WLANS_$${dev}}; \
		for wlan in $${all_wlans}; do \
			{ \
				eval wlan_args="\$${WLANS_$${wlan}_ARGS}" && \
				ifconfig $${wlan} create wlandev $${dev} && \
				{ \
					ifconfig $${wlan} $${wlan_args}; \
					ifconfig $${wlan} up; \
				}; \
			} || echo "MRC:$@> ERROR: WLAN $${wlan} failed to initialize."; \
		done \
	done

zfs:
.if empty(ZFS_ENABLE:tl:Mno)
	zfs mount -va || exit $$?
	zfs share -a || exit $$?
	touch /etc/zfs/exports
.endif

runshm: cleanvar
	echo "MRC:$@> Preparing /var/run."
.	if exists(TMPFS_VAR_RUN_ENABLE)
	/rescue/find /var/run -mindepth 1 -delete
	mount_tmpfs dummy /var/run
.	else
	mkdir -p /var/run/shm
	mount_tmpfs -m 01777 dummy /var/run/shm
.	endif
	mtree -deiqU -f /etc/mtree/BSD.var.dist -p /var

mounttmpfs: cleanvar
	echo "MRC:$@> Mount tmpfs and populating /var/run."
.if exists(TMPFS_TMP_ENABLE)
	mount | awk 'BEGIN{x=1}$$3~/\/tmp/{x=0}END{exit(x)}' || { \
		/rescue/find /tmp -mindepth 1 -delete; \
		mount_tmpfs -m 01777 dummy /tmp; \
	}
.endif

udevd_check: DAEMON
	echo "MRC:$@> Check udevd PID/socket are accessible."
	if [ ! -e /var/run/udevd.pid -o ! -e /tmp/udevd.socket ]; then \
		pkill -HUP -x udevd; \
		( \
			sleep 1; \
			if [ ! -e /var/run/udevd.pid -o ! -e /tmp/udevd.socket ]; then \
				svc restart udevd; \
			fi \
		) & \
	fi

utmpx: runshm
	echo "MRC:$@> Install utmpx."
	install -m 644 -g wheel /dev/null /var/run/utmpx
