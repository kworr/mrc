DAEMON_cron_COMMAND?=/usr/sbin/cron
DAEMON_cron_ENABLE?=yes

# using daemon so that cron can start newsyslog which is sending signals
# to other processes
cron: ${_SERVICE_DAEMON}
