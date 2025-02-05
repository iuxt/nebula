#!/bin/bash
set -euo pipefail


if [ "$(id -u)" != "0" ]; then
    echo "Error: 必须使用ROOT用户来运行， 你可以在命令前面加上 sudo "
    exit 1
fi


# 日志处理
../public/docker_logs_link.sh basename $(cd $(dirname $0) && pwd)

# nginx-http-cc
cp -f filter.d/nginx-http-cc.conf /etc/fail2ban/filter.d/
cp -f jail.d/nginx-http-cc.conf /etc/fail2ban/jail.d/

# nginx-stream-cc
cp -f filter.d/nginx-stream-cc.conf /etc/fail2ban/filter.d/
cp -f jail.d/nginx-stream-cc.conf /etc/fail2ban/jail.d/


systemctl enable fail2ban
systemctl reload fail2ban

fail2ban-client status nginx-http-cc
fail2ban-client status nginx-stream-cc

