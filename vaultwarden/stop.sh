#!/bin/bash
cd $(dirname $0)

docker rm -f vaultwarden

# 生效nginx规则
rm -f ../nginx/conf.d/"$(basename "$(pwd)")".conf
../nginx/reload.sh


# fail2ban规则
rm -f ../../fail2ban/config/fail2ban/jail.d/vaultwarden.conf

docker exec -it fail2ban fail2ban-client reload
docker exec -it fail2ban fail2ban-client status

