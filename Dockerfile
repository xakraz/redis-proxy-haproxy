FROM haproxy:2.1.2-alpine

COPY rootfs /

# Ripped from: https://github.com/docker-library/haproxy/blob/master/2.1/alpine/docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]