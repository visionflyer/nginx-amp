FROM nginx:latest
MAINTAINER Thomas Ebenrett <thomas@thomasebenrett.de>

# Install the NGINX Amplify Agent
RUN apt-get update \
    && apt-get install -qqy curl python apt-transport-https apt-utils gnupg1 procps wget telnet nano vim net-tools logrotate cron openssh-server sudo\
    && echo 'deb https://packages.amplify.nginx.com/debian/ stretch amplify-agent' > /etc/apt/sources.list.d/nginx-amplify.list \
    && curl -fs https://nginx.org/keys/nginx_signing.key | apt-key add - > /dev/null 2>&1 \
    && apt-get update \
    && apt-get install -qqy nginx-amplify-agent \
    && rm -rf /var/lib/apt/lists/*

# sshd
RUN mkdir /var/run/sshd \
    && echo 'root:screencast' | chpasswd \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN rm /bin/sh && ln -s /bin/bash /bin/sh


# Keep the nginx logs inside the container
RUN unlink /var/log/nginx/access.log \
    && unlink /var/log/nginx/error.log \
    && touch /var/log/nginx/access.log \
    && touch /var/log/nginx/error.log \
    && chown nginx /var/log/nginx/*log \
    && chmod 644 /var/log/nginx/*log \
    && ln -sf /dev/stdout /var/log/amplify-agent/agent.log


# Copy nginx stub_status config
COPY ./conf.d/stub_status.conf /etc/nginx/conf.d
# Copy nginx default config
COPY ./conf.d/default.conf /etc/nginx/conf.d
# Copy nginx default certs
COPY  ./conf.d/*.pem /var/www/certs/

#Stream conf
RUN mkdir -p /etc/nginx/streamconf.d
RUN echo " \
stream { \
	include /etc/nginx/streamconf.d/*; \
}" >> /etc/nginx/nginx.conf

COPY ./nginx /etc/logrotate.d/
COPY ./entrypoint.sh /entrypoint.sh
EXPOSE 443
EXPOSE 80
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
