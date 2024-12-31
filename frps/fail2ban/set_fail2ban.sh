#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "Error: 必须使用ROOT用户来运行， 你可以在命令前面加上 sudo "
    exit 1
fi

# frps
cp -f filter.d/frps.conf /etc/fail2ban/filter.d/
cp -f jail.d/frps.conf /etc/fail2ban/jail.d/
container_id=$(docker inspect --format="{{.Id}}" frps)
logpath=/var/lib/docker/containers/${container_id}/${container_id}-json.log
sed -i "s#logpath = .*#logpath = ${logpath}#g" /etc/fail2ban/jail.d/frps.conf
fail2ban-regex ${logpath} /etc/fail2ban/filter.d/frps.conf

systemctl enable fail2ban
systemctl reload fail2ban
fail2ban-client status frps
