#! /bin/sh -xe

CONF=/usr/local/lib/udp.tmpl

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
    listen $PORT_LISTEN udp;
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
