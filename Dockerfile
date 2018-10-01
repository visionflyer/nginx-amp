FROM nginx:1.15.2
MAINTAINER Thomas Ebenrett <thomas@thomasebenrett.de>

# Install the NGINX Amplify Agent
RUN apt-get update \
    && apt-get install -qqy curl python apt-transport-https apt-utils gnupg1 procps wget telnet nano vim net-tools\
    && echo 'deb https://packages.amplify.nginx.com/debian/ stretch amplify-agent' > /etc/apt/sources.list.d/nginx-amplify.list \
    && curl -fs https://nginx.org/keys/nginx_signing.key | apt-key add - > /dev/null 2>&1 \
    && apt-get update \
    && apt-get install -qqy nginx-amplify-agent \
    && apt-get purge -qqy curl apt-transport-https apt-utils gnupg1 \
    && rm -rf /var/lib/apt/lists/*

# Keep the nginx logs inside the container
RUN unlink /var/log/nginx/access.log \
    && unlink /var/log/nginx/error.log \
    && touch /var/log/nginx/access.log \
    && touch /var/log/nginx/error.log \
    && chown nginx /var/log/nginx/*log \
    && chmod 644 /var/log/nginx/*log

# Copy nginx stub_status config
COPY ./conf.d/stub_status.conf /etc/nginx/conf.d
# Copy nginx default config
COPY ./conf.d/default.conf /etc/nginx/conf.d

#Stream conf
RUN mkdir -p /etc/nginx/streamconf.d
RUN echo " \
stream { \
	include /etc/nginx/streamconf.d/*; \
}" >> /etc/nginx/nginx.conf

# API_KEY is required for configuring the NGINX Amplify Agent.
# It could be your real API key for NGINX Amplify here if you wanted
# to build your own image to host it in a private registry.
# However, including private keys in the Dockerfile is not recommended.
# Use the environment variables at runtime as described below.

#ENV API_KEY 1234567890

# If AMPLIFY_IMAGENAME is set, the startup wrapper script will use it to
# generate the 'imagename' to put in the /etc/amplify-agent/agent.conf
# If several instances use the same 'imagename', the metrics will
# be aggregated into a single object in NGINX Amplify. Otherwise Amplify
# will create separate objects for monitoring (an object per instance).
# AMPLIFY_IMAGENAME can also be passed to the instance at runtime as
# described below.

#ENV AMPLIFY_IMAGENAME my-docker-instance-123

# The /entrypoint.sh script will launch nginx and the Amplify Agent.
# The script honors API_KEY and AMPLIFY_IMAGENAME environment
# variables, and updates /etc/amplify-agent/agent.conf accordingly.
#ENV HTTPS_PROXY  http://127.0.0.1:4480


COPY ./entrypoint.sh /entrypoint.sh

# TO set/override API_KEY and AMPLIFY_IMAGENAME when starting an instance:
# docker run -p 9100:80 --name nginx-amp -e API_KEY=f2ca61f5c91948adb63842b36d6d6156 -e AMPLIFY_IMAGENAME=nginx -e HTTPS_PROXY_IP=1827 -e HTTPS_PROXY_PORT=1234 nginx-amplify amplify
# amplify at the end is $1 command paramter for entrypoint.sh, without this amplify will not starting

ENTRYPOINT ["/entrypoint.sh"]
