# Dockerized Hysteria 2 (hy2) Proxy

This Docker image provides a simple way to deploy a Hysteria 2 (hy2) proxy server.

[Docker Hub](https://hub.docker.com/r/fontlos/hysteria2)

[Example Link](https://fontlos.com/post/2025-05-07)

```
fontlos/hysteria2:latest
```

## Default Configuration

The image comes with a default configuration for the Hysteria 2 proxy:

```yaml
listen: :33333
speedTest: true
tls:
  cert: /etc/hysteria/default_certs/default.crt
  key: /etc/hysteria/default_certs/default.key
  sniGuard: disable
auth:
  type: password
  password: YourStrongPasswordHere
```

**Important:** You should change the default `password` for security reasons.

## Custom Configuration

You can override the default configuration by mounting a `/data` volume and placing your custom `/data/s.yaml` configuration file inside it.

## SSL/TLS Certificates with Certbot (Cloudflare DNS)

This image includes Certbot, allowing you to obtain SSL/TLS certificates from Let's Encrypt. If your domain is managed by Cloudflare, you can use the DNS challenge method for certificate issuance. This is particularly useful for SNI (Server Name Indication) verification, ensuring that TLS handshakes only succeed if the SNI matches your domain.

### Prerequisites for Certbot with Cloudflare:

1.  **Cloudflare API Token:** Create a Cloudflare API token with permissions to edit DNS records for your domain.
2.  **Cloudflare Credentials File:** Create a `cloudflare.ini` file with your Cloudflare API token:

    ```ini
    dns_cloudflare_api_token = YOUR_CLOUDFLARE_API_TOKEN
    ```

### Obtaining a Certificate

```bash
certbot certonly \
    --config-dir /data/letsencrypt_config \
    --work-dir /data/letsencrypt_config/work \
    --logs-dir /data/letsencrypt_config/logs \
    --dns-cloudflare \
    --dns-cloudflare-credentials /data/cloudflare_secrets/cloudflare.ini \
    --dns-cloudflare-propagation-seconds 30 \
    -d <YOUR_DOMAIN> \
    --agree-tos \
    --email <YOUR_EMAIL> \
    --no-eff-email
```

Replace `<YOUR_DOMAIN>` with your actual domain name and `<YOUR_EMAIL>` with your email address.

The obtained certificates will be stored in `/data/letsencrypt_config/live/<YOUR_DOMAIN>/`. You should then update your `s.yaml` to point to these certificate files:

```yaml
tls:
  cert: /data/letsencrypt_config/live/<YOUR_DOMAIN>/fullchain.pem
  key: /data/letsencrypt_config/live/<YOUR_DOMAIN>/privkey.pem
  sniGuard: strict # Enable SNI guard if desired
```

### Simulating Certificate Renewal

You can test the certificate renewal process (without actually renewing) using:

```bash
certbot renew \
    --config-dir /data/letsencrypt_config \
    --work-dir /data/letsencrypt_config/work \
    --logs-dir /data/letsencrypt_config/logs \
    --dry-run
```

### Automatic Certificate Renewal

To set up automatic renewal, you can create a cron job on your host system or within the container to run the `certbot renew` command periodically.

## TODO

* **Hot Reloading Certificates:** Currently, after renewing certificates, you need to manually restart the Hysteria 2 service (e.g., by restarting the Docker container) for the changes to take effect. A mechanism for hot reloading certificates and automatically restarting the Hysteria service upon renewal is needed.

## Contributing

Feel free to open issues or submit pull requests if you have suggestions or improvements.
