#!/usr/bin/env sh

set -e


# == Templating
#
echo "===> Templating Haproxy.cfg"

haproxy_config_dir="${HAPROXY_CONF_DIR:-/usr/local/etc/haproxy}"

if [ -z "$PROXY_PORT" ]; then
    export PROXY_PORT=6379
fi
echo "     * PROXY_PORT=${PROXY_PORT}"


if [ -z "$REDIS_HOST" ]; then
    echo "Environment variable REDIS_HOST is not set"
    exit 1
fi
echo "     * REDIS_HOST=${REDIS_HOST}"


if [ -z "$REDIS_PORT" ]; then
    export REDIS_PORT=6379
elif [[ "$REDIS_PORT" =~ "tcp://" ]]; then
   export REDIS_PORT=6379
fi
echo "     * REDIS_PORT=${REDIS_PORT}"


if [ -z "$DNS_RESOLVER" ]; then
    # AWS VCP
    export DNS_RESOLVER=169.254.169.253
fi
echo "     * DNS_RESOLVER=${DNS_RESOLVER}"


if [ -z "$ADMIN_USER" ]; then
    export ADMIN_USER=admin
fi
echo "     * ADMIN_USER=${ADMIN_USER}"

if [ -z "$ADMIN_PASSWORD" ]; then
    export ADMIN_PASSWORD=password
fi
echo "     * ADMIN_PASSWORD=****"

sed -i'' "s/%{PROXY_PORT}/${PROXY_PORT}/" "${haproxy_config_dir}/haproxy.cfg"
sed -i'' "s/%{REDIS_HOST}/${REDIS_HOST}/" "${haproxy_config_dir}/haproxy.cfg"
sed -i'' "s/%{REDIS_PORT}/${REDIS_PORT}/" "${haproxy_config_dir}/haproxy.cfg"
sed -i'' "s/%{DNS_RESOLVER}/${DNS_RESOLVER}/" "${haproxy_config_dir}/haproxy.cfg"

sed -i'' "s/%{ADMIN_USER}/${ADMIN_USER}/" "${haproxy_config_dir}/haproxy.cfg"
sed -i'' "s/%{ADMIN_PASSWORD}/${ADMIN_PASSWORD}/" "${haproxy_config_dir}/haproxy.cfg"


echo "===> Testing config Haproxy.cfg"
cat "${haproxy_config_dir}/haproxy.cfg"
echo ''
haproxy -c -f "${haproxy_config_dir}/haproxy.cfg"


# == Original entrypoint
#
echo "===> Starting haproxy"
# Ripped from https://github.com/docker-library/haproxy/blob/master/2.1/alpine/docker-entrypoint.sh
#
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
	shift # "haproxy"
	# if the user wants "haproxy", let's add a couple useful flags
	#   -W  -- "master-worker mode" (similar to the old "haproxy-systemd-wrapper"; allows for reload via "SIGUSR2")
	#   -db -- disables background mode
	set -- haproxy -W -db "$@"
fi

exec "$@"