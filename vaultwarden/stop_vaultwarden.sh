#!/bin/bash
cd $(dirname $0)

docker rm -f vaultwarden

# 生效nginx规则
rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf
../nginx/reload_nginx.sh


# fail2ban规则
rm -f /etc/fail2ban/jail.d/vaultwarden.conf
systemctl enable fail2ban
systemctl reload fail2ban

fail2ban-client status

