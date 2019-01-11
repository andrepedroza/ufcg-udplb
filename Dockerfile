FROM ubuntu:16.04

RUN apt update \
    && apt install -y ca-certificates bash vim nginx supervisor

ENV RANCHER_GEN_RELEASE=v0.2.0

ADD https://github.com/janeczku/go-rancher-gen/releases/download/${RANCHER_GEN_RELEASE}/rancher-gen-linux-amd64.tar.gz /tmp/rancher-gen.tar.gz
RUN tar -zxvf /tmp/rancher-gen.tar.gz -C /usr/local/bin && chmod +x /usr/local/bin/rancher-gen

ENV BACKEND=main \
    PORT_BACKEND=53 \
    PORT_LISTEN=53

EXPOSE 53
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
