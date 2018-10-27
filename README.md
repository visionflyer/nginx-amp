# NGiNX with amplify?

This Image is providing nginx:1.15.2 and Amplify Agent. 

# Use Amplifiy

You have to set the following environment Variables:

* API_KEY  - this is your amplify API Key provided bei amplify Service
* AMPLIFY_IMAGENAME - this is the name of the NGiNX instance in amplify Portal


# Use Proxy

Use behind a corporate proxy with the environment Variables:

* HTTPS_PROXY_IP - IP Adress of proxy
* HTTPS_PROXY_PORT - Port of proxy

# Use a self signed certificate

To generate a self signed certificate in:

* SELF_SIGNED_ISSUER_URL - url the certificate is dedicated to
* default cert dir /etc/ssl/certs/self-cert.pem 
* default key dir /etc/ssl/certs/self-key.pem 

To set a custom Directory to save the self-cert.pem and self-key.pem (SELF_SIGEND_ISSUER_URL must be set) use:

* SELF_SIGNED_DIR


# Full exymple to run

```bash
docker run -p 9100:80 --name nginx-amp -e API_KEY=yourKey -e AMPLIFY_IMAGENAME=nginx_with_amp -e HTTPS_PROXY_IP=yourProxyIp -e HTTPS_PROXY_PORT=yourProxyPort -e SELF_SIGNED_ISSUER_URL=example.com -e -e SELF_SIGNED_DIR=/var/www/certs visionflyer/nginx-amp amplify
```

The amplify CMD at the end must be present, without the Container is not going to start Amplify
