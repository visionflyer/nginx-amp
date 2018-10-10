#!/bin/sh

# Variables
agent_conf_file="/etc/amplify-agent/agent.conf"
agent_log_file="/var/log/amplify-agent/agent.log"
nginx_status_conf="/etc/nginx/conf.d/stub_status.conf"
api_key=""
amplify_imagename=""
https_proxy_ip=""
https_proxy_port=""
nginx_auto_reload_cron_minutes=""

# Launch nginx
echo "starting nginx ..."
nginx -g "daemon off;" &


nginx_pid=$!


if [ "$1" = 'amplify' ]; then
echo "Starte mit amplify"

test -n "${API_KEY}" && \
    api_key=${API_KEY}

test -n "${AMPLIFY_IMAGENAME}" && \
    amplify_imagename=${AMPLIFY_IMAGENAME}

test -n "${HTTPS_PROXY_IP}" && \
    https_proxy_ip=${HTTPS_PROXY_IP}

test -n "${HTTPS_PROXY_PORT}" && \
    https_proxy_port=${HTTPS_PROXY_PORT}

test -n "${NGINX_AUTO_RELOAD_CRON_MINUTES}" && \
    nginx_auto_reload_cron_minutes=${NGINX_AUTO_RELOAD_CRON_MINUTES}

if[[ -z $nginx_auto_reload_cron_minutes && ${nginx_auto_reload_cron_minutes+x}]];
	then
	sh -c 'echo "*/${NGINX_AUTO_RELOAD_CRON_MINUTES} * * * * nginx -s reload" | crontab'
	else
	sh -c 'echo "" | crontab'
fi


if [ -n "${api_key}" -o -n "${amplify_imagename}" ]; then
    echo "updating ${agent_conf_file} ..."

echo "API_KEY ${API_KEY}"
echo "AMPLIFY_IMAGENAME ${AMPLIFY_IMAGENAME}"
echo "HTTPS_PROXY ${HTTPS_PROXY}"


echo "amplify_imagename ${amplify_imagename}"
echo "api_key ${api_key}"
echo "https_proxy_ip ${https_proxy_ip}"
echo "https_proxy_port ${https_proxy_port}"



    if [ ! -f "${agent_conf_file}" ]; then
test -f "${agent_conf_file}.default" && \
cp -p "${agent_conf_file}.default" "${agent_conf_file}" || \
{ echo "no ${agent_conf_file}.default found! exiting."; exit 1; }
    fi

    test -n "${api_key}" && \
    echo " ---> using api_key = ${api_key}" && \
    sh -c "sed -i.old -e 's/api_key.*$/api_key = $api_key/' \
${agent_conf_file}"

    test -n "${amplify_imagename}" && \
    echo " ---> using imagename = ${amplify_imagename}" && \
    sh -c "sed -i.old -e 's/imagename.*$/imagename = $amplify_imagename/' \
${agent_conf_file}"
 
    test -n "${https_proxy_ip}" && \
    echo " ---> using proxy https = ${https_proxy_ip}:${https_proxy_port}" && \
    sh -c "sed -i.old -e '0,/https.*$/ s/https.*$/https = http:\/\/${https_proxy_ip}:${https_proxy_port}/' \
${agent_conf_file}"

    test -f "${agent_conf_file}" && \
    chmod 644 ${agent_conf_file} && \
    chown nginx ${agent_conf_file} > /dev/null 2>&1

    test -f "${nginx_status_conf}" && \
    chmod 644 ${nginx_status_conf} && \
    chown nginx ${nginx_status_conf} > /dev/null 2>&1
fi

if ! grep '^api_key.*=[ ]*[[:alnum:]].*' ${agent_conf_file} > /dev/null 2>&1; then
    echo "no api_key found in ${agent_conf_file}! exiting."
fi

echo "starting amplify-agent ..."
service amplify-agent start > /dev/null 2>&1 < /dev/null

if [ $? != 0 ]; then
    echo "couldn't start the agent, please check ${agent_log_file}"
    exit 1
fi
else
echo "Starte ohne amplify"

fi
wait ${nginx_pid}

echo "nginx master process has stopped, exiting."
