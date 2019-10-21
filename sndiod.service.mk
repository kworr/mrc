DAEMON_sndiod_COMMAND?=/usr/local/bin/sndiod
DAEMON_sndiod_ENABLE?=no
DAEMON_sndiod_FLAGS?=-c 0:7 -j off -s default -m mon -s monitor -d

sndiod: _service
