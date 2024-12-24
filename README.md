# MRC is init replacement for DragonFly BSD, written in BSD Make.

- Can start services in parallel.
- Can manage services differently: via svc/daemon/just by starting them in
  background.
- Faster and easier on resources comparing to rc.d, for example whole
  configuration is prepared only once before running anything, rc.d is
  calculating all variables for each service independently.
- Service definition is simplified a lot.
- Naming and logic is not yet finalized.
- Fun (for me).

!!!WARNING!!! This is a project in an alpha stage done for pure fun, that
replaces system functionality and may prevent your system from correctly
booting up. In case you run into any issues make sure to replace `/etc/rc`
and `/etc/rc.shutdown` with default versions by running:

```Shell
cp -f /usr/src/etc/rc /etc/
cp -f /usr/src/etc/rc.shutdown /etc/
```

This also means you need to have sources checked out to `/usr/src`.

## Install

Checkout this to /etc/mrc, `cd /etc/mrc && make install`.

## Configuration

Can be configured almost the same way as rc.d, by editing `/etc/mrc.mk`.
Syntax used is Make syntax:

```Make
DUMPDEV=/dev/serno/something.s5
HOSTNAME=Amnesiac
KLD_LIST=ahci wlan_ccmp wlan_amrr wlan_rssadapt acpi_wmi aesni snd_hda amdtemp ums nvmm amdsbwd acpi_video if_iwm radeon
WLANS_iwm0=wlan0
WLANS_wlan0_ARGS=country UA powersave
RPC_UMNTALL_ENABLE=yes

DAEMON_automountd_ENABLE=yes
DAEMON_dhcpcd_ENABLE=yes
DAEMON_inetd_ENABLE=yes
DAEMON_powerd_ENABLE=yes

#DAEMON_slim_ENABLE=yes
DAEMON_dntpd_ENABLE=yes
#DAEMON_smartd_ENABLE=yes
DAEMON_bsdstats_ENABLE=yes
DAEMON_lldpd_ENABLE=yes
DAEMON_moused_ENABLE=no
DAEMON_wpa_supplicant_ENABLE=yes
DAEMON_arpwatch_ENABLE=yes
DAEMON_dbus_ENABLE=yes

DAEMON_sensorsd_ENABLE=yes
#DAEMON_sndiod_ENABLE=yes
```

## Usage

You can control services directly via `svc` or `daemon`, or you can use special
targets under `/etc/mrc`:

```Shell
# this will start service if it's enabled
$ make <service>

# this will show running service _status
$ make <service>_status

# stop and deconstruct service, removing running svc/daemon instance
$ make <service>_exit
```
