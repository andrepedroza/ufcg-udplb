#! /bin/sh -xe

cat <<EOF > /usr/local/lib/udp.tmpl
load_module /usr/lib/nginx/modules/ngx_stream_module.so;
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
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

supervisord -c /etc/supervisor/supervisord.conf
