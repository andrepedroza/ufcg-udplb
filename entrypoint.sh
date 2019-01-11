#! /bin/sh -xe

CONF=/usr/local/lib/udp.tmpl

SELF_IP=$(ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
if [ "$IP_LISTEN" == self ]; then
  if [ -z "$SELF_IP" ]; then
    echo Could not determine IP for interface=$INTERFACE
    exit 1
  fi
  LISTEN=$SELF_IP:$PORT_LISTEN
elif [ ! -z "$IP_LISTEN" ]; then
  LISTEN=$LISTEN_IP:$PORT_LISTEN
else
  LISTEN=$PORT_LISTEN
fi

if [ ! -s /usr/local/lib/udp.conf ]; then
  cat <<EOF > $CONF
stream {
  upstream backends {
{{with service "$BACKEND"}}
  {{range .Containers}}
    server {{.Address}}:$PORT_BACKEND weight=10;
  {{end}}
{{end}}
  }
  server {
    listen $LISTEN udp;
    proxy_pass backends;
    proxy_responses 1;
    error_log stderr;
  }
}
EOF
fi

if [ ! -e /etc/nginx/.configured ]; then
  cat $CONF >> /etc/nginx/nginx.conf
  touch /etc/nginx/.configured
fi

supervisord
