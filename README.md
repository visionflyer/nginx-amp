# nginx-amp

NGINX mit Amplify
ENV Variablen

API_KEY
AMPLIFY_IMAGENAME
HTTPS_PROXY_IP
HTTPS_PROXY_PORT
SELF_SIGNED_ISSUER_URL


TO set/override API_KEY and AMPLIFY_IMAGENAME when starting an instance:
docker run -p 9100:80 --name nginx-amp -e API_KEY=yourKey -e AMPLIFY_IMAGENAME=nginx nginx-amplify amplify

TO set a HTTPS Proxy
docker run -p 9100:80 --name nginx-amp -e API_KEY=yourKey -e AMPLIFY_IMAGENAME=nginx -e HTTPS_PROXY_IP=yourProxyIp -e HTTPS_PROXY_PORT=yourProxyPort visionflyer/nginx-amp amplify

The amplify CMD at the end must be present, without the Container is not going to start Amplify

Setting up self signed Cert

If you set ENV/-e SELF_SIGNED_ISSUER_URL on Container a self signed cert/key pair is created on this url at /etc/ssl/certs/self-cert.pem - /etc/ssl/certs/self-key.pem  