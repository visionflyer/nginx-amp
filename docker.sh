docker stop nginxtest
docker rm nginxtest
docker build -t nginxtest .
docker run -p 9201:443 -p 9200:80 --name nginxtest -e SELF_SIGNED_ISSUER_URL=appctest.enviam-gruppe.de -e SELF_SIGNED_DIR=/var/www/certs nginxtest
