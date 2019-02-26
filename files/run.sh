#!/bin/sh

HAPROXY_FOLDER="/usr/local/etc/haproxy"
HAPROXY_CFG="${HAPROXY_FOLDER}/haproxy.cfg"
HAPROXY_PID="/var/run/haproxy.pid"
HAPROXY_RUN="/usr/local/sbin/haproxy -f ${HAPROXY_CFG} -D -p ${HAPROXY_PID}"
HAPROXY_CFG_VALIDATE="/usr/local/sbin/haproxy -f ${HAPROXY_CFG} -c"

RSYSLOG_PID="/var/run/rsyslogd.pid"
RSYSLOG_RUN="/usr/sbin/rsyslogd"

TLS_CERT="${HAPROXY_FOLDER}/node.crt"
TLS_KEY="${HAPROXY_FOLDER}/node.key"
TLS_CHAIN="${HAPROXY_FOLDER}/node.pem"

echo "Creating cert/key file..."
/bin/cat "${TLS_CERT}" "${TLS_KEY}" > "${TLS_CHAIN}"
echo "Cert/key file created."

echo "Starting rsyslogd..."
rm -rf "${RSYSLOG_PID}"
${RSYSLOG_RUN}
echo "Rsyslogd started."

echo "Starting HAProxy..."
${HAPROXY_CFG_VALIDATE}
${HAPROXY_RUN}
echo "HAProxy started."

echo "Watching for changes to HAProxy config or cert/key..."

inotifywait -m "${HAPROXY_CFG}" "${TLS_CERT}" "${TLS_KEY}" -e create,delete,modify,attrib |
  while read path; do
    /bin/cat "${TLS_CERT}" "${TLS_KEY}" > "${TLS_CHAIN}"

    if [ -f "${HAPROXY_PID}" ]; then
      echo "Restart HAProxy due to file changes in folder..."
      ${HAPROXY_CFG_VALIDATE}
      ${HAPROXY_RUN} -sf $(/bin/cat "${HAPROXY_PID}")
      echo "HAProxy restarted."
    else
      echo "No HAProxy PID file found. Exiting."
      exit 1
    fi
  done 

