FROM nginx:1.15-alpine

RUN apk add --no-cache ca-certificates supervisor

ENV RANCHER_GEN_RELEASE=v0.2.0

ADD https://github.com/janeczku/go-rancher-gen/releases/download/${RANCHER_GEN_RELEASE}/rancher-gen-linux-amd64.tar.gz /tmp/rancher-gen.tar.gz
RUN tar -zxvf /tmp/rancher-gen.tar.gz -C /usr/local/bin && chmod +x /usr/local/bin/rancher-gen

RUN touch /etc/nginx/udp.conf && echo "stream { include /etc/nginx/udp.conf; }" >> /etc/nginx/nginx.conf

ENV BACKEND=main \
    INTERFACE=eth0 \
    IP_LISTEN= \
    PORT_BACKEND=53 \
    PORT_LISTEN=53

EXPOSE 53
VOLUME /usr/local/lib
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
