FROM alpine:3.20

ARG HYSTERIA_VERSION="app/v2.6.1"
ARG HYSTERIA_ARCH="amd64"

LABEL org.opencontainers.image.authors="Fontlos <fontlos@fontlos.com>" \
      org.opencontainers.image.title="Hysteria2" \
      org.opencontainers.image.description="Alpine-based Docker Image for Hysteria2 proxy, including Certbot, DNS Cloudflare plugin, and default self-signed certificates for initial startup."

RUN apk update && apk add --no-cache \
    ca-certificates \
    wget \
    certbot \
    certbot-dns-cloudflare \
    openssl

RUN wget "https://github.com/apernet/hysteria/releases/download/${HYSTERIA_VERSION}/hysteria-linux-${HYSTERIA_ARCH}" -O /tmp/hy \
    && chmod +x /tmp/hy \
    && mv /tmp/hy /usr/local/bin/hy

RUN mkdir -p /etc/hysteria/default_certs

RUN openssl genrsa -out /etc/hysteria/default_certs/default.key 2048 && \
    openssl req -new -x509 -key /etc/hysteria/default_certs/default.key -out /etc/hysteria/default_certs/default.crt -days 36000 -subj "/CN=hysteria.local.default"

RUN mkdir -p /data

RUN echo "listen: :33333" > /data/s.yaml && \
    echo "speedTest: true" >> /data/s.yaml && \
    echo "tls:" >> /data/s.yaml && \
    echo "  cert: /etc/hysteria/default_certs/default.crt" >> /data/s.yaml && \
    echo "  key: /etc/hysteria/default_certs/default.key" >> /data/s.yaml && \
    echo "  sniGuard: disable" >> /data/s.yaml && \
    echo "auth:" >> /data/s.yaml && \
    echo "  type: password" >> /data/s.yaml && \
    echo "  password: YourStrongPasswordHere" >> /data/s.yaml

ENTRYPOINT ["/usr/local/bin/hy"]

CMD ["server", "-c", "/data/s.yaml"]
