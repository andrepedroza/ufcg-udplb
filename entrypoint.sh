#! /bin/sh -xe

cat <<EOF > /usr/local/lib/udp.tmpl
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

supervisord -c /etc/supervisor/conf.d/supervisord.conf
