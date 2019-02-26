FROM haproxy:1.9.4-alpine

ENV HAPROXY_GROUP_ID=1000 \
    HAPROXY_USER_ID=1000

RUN mkdir -p /etc/rsyslog.d 

COPY files/run.sh /
COPY files/etc/rsyslog.conf /etc/

RUN apk add --no-cache inotify-tools ca-certificates rsyslog && \
    addgroup -g ${HAPROXY_GROUP_ID} haproxy && \
    adduser -D -u ${HAPROXY_USER_ID} -G haproxy haproxy && \
    mkdir -p /var/lib/haproxy && \
    chown -R haproxy:haproxy /var/lib/haproxy && \
    chown -R haproxy:haproxy /etc/rsyslog.d && \
    touch /var/log/haproxy.log && \
    chown haproxy:haproxy /var/log/haproxy.log && \
    chown haproxy:haproxy /run.sh && \
    ln -sf /dev/stdout /var/log/haproxy.log && \
    chmod +x /run.sh

WORKDIR /

ENTRYPOINT /run.sh

