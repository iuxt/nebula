#!/bin/bash
set -euo pipefail
cd $(dirname $0)

if [ "$(id -u)" != "0" ]; then
    echo "Error: 必须使用ROOT用户来运行， 你可以在命令前面加上 sudo "
    exit 1
fi

# vaultwarden
cp -f filter.d/vaultwarden.conf ../../fail2ban/config/fail2ban/filter.d/
cp -f jail.d/vaultwarden.conf ../../fail2ban/config/fail2ban/jail.d/


docker exec fail2ban fail2ban-client reload

docker exec fail2ban fail2ban-client status vaultwarden
