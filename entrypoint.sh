#! /bin/sh -xe

cat <<EOF > /usr/local/lib/udp.tmpl
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
    # multi_accept on;
}

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

supervisord
