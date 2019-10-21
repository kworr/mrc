DAEMON_node_exporter_COMMAND?=/usr/local/bin/node_exporter --web.listen-address=${DAEMON_node_exporter_LISTEN_ADDRESS} --collector.textfile.directory=${DAEMON_node_exporter_TEXTFILE_DIR}
DAEMON_node_exporter_ENABLE?=no
DAEMON_node_exporter_LISTEN_ADDRESS?=:9100
DAEMON_node_exporter_TEXTFILE_DIR?=/var/tmp/node_exporter
DAEMON_node_exporter_USER?=nobody
DAEMON_node_exporter_GROUP?=nobody

node_exporter: _service
	test -z "$${DAEMON_$@_ENABLE}" || \
	install -d -o ${DAEMON_node_exporter_USER} -g ${DAEMON_node_exporter_GROUP} -m1755 ${DAEMON_node_exporter_TEXTFILE_DIR}
